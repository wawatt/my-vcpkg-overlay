#include <tesseract/motion_planners/ompl/vamp_support.h>

#include <tesseract/common/macros.h>
TESSERACT_COMMON_IGNORE_WARNINGS_PUSH
#include <ompl/geometric/SimpleSetup.h>
#include <ompl/vamp/VampMotionValidator.h>
#include <ompl/vamp/VampStateValidityChecker.h>
#include <vamp/collision/environment.hh>
#include <vamp/collision/factory.hh>
#include <vamp/robots/fetch.hh>
#include <vamp/robots/panda.hh>
#include <vamp/robots/ur5.hh>
#include <console_bridge/console.h>
#include <unordered_set>
TESSERACT_COMMON_IGNORE_WARNINGS_POP

#include <tesseract/environment/environment.h>
#include <tesseract/geometry/geometries.h>
#include <tesseract/kinematics/joint_group.h>
#include <tesseract/scene_graph/graph.h>
#include <tesseract/scene_graph/link.h>
#include <tesseract/scene_graph/scene_state.h>

namespace tesseract::motion_planners
{
namespace
{
using VampEnvF = vamp::collision::Environment<float>;
using VampEnv = vamp::collision::Environment<vamp::FloatVector<vamp::FloatVectorWidth>>;

template <typename Robot>
bool jointsMatch(const std::vector<std::string>& names)
{
  if (names.size() != Robot::dimension)
    return false;
  for (std::size_t i = 0; i < Robot::dimension; ++i)
  {
    if (names[i] != Robot::joint_names[i])
      return false;
  }
  return true;
}

void appendShape(VampEnvF& venv,
                 const tesseract::geometry::Geometry& geom,
                 const Eigen::Isometry3d& T_world)
{
  const Eigen::Vector3f center = T_world.translation().cast<float>();
  const Eigen::Quaternionf rot(T_world.linear().cast<float>());

  switch (geom.getType())
  {
    case tesseract::geometry::GeometryType::SPHERE:
    {
      const auto& s = static_cast<const tesseract::geometry::Sphere&>(geom);
      venv.spheres.emplace_back(vamp::collision::factory::sphere::eigen(center, static_cast<float>(s.getRadius())));
      break;
    }
    case tesseract::geometry::GeometryType::BOX:
    {
      const auto& b = static_cast<const tesseract::geometry::Box&>(geom);
      const Eigen::Vector3f half_extents(static_cast<float>(b.getX() * 0.5),
                                         static_cast<float>(b.getY() * 0.5),
                                         static_cast<float>(b.getZ() * 0.5));
      venv.cuboids.emplace_back(vamp::collision::factory::cuboid::eigen_rot(center, rot, half_extents));
      break;
    }
    case tesseract::geometry::GeometryType::CYLINDER:
    {
      const auto& c = static_cast<const tesseract::geometry::Cylinder&>(geom);
      venv.cylinders.emplace_back(vamp::collision::factory::cylinder::center::eigen_rot(
          center, rot, static_cast<float>(c.getRadius()), static_cast<float>(c.getLength())));
      break;
    }
    case tesseract::geometry::GeometryType::CAPSULE:
    {
      const auto& c = static_cast<const tesseract::geometry::Capsule&>(geom);
      venv.capsules.emplace_back(vamp::collision::factory::capsule::center::eigen_rot(
          center, rot, static_cast<float>(c.getRadius()), static_cast<float>(c.getLength())));
      break;
    }
    default:
      CONSOLE_BRIDGE_logDebug("VAMP: skipping unsupported world geometry type %s",
                              tesseract::geometry::GeometryTypeStrings[static_cast<int>(geom.getType())].c_str());
      break;
  }
}

VampEnvF buildWorld(const tesseract::environment::Environment& env, const std::vector<std::string>& skip_links)
{
  VampEnvF venv;
  const std::unordered_set<std::string> skip(skip_links.begin(), skip_links.end());
  const auto scene = env.getSceneGraph();
  const auto state = env.getState();
  if (scene == nullptr)
    return venv;

  for (const auto& link : scene->getLinks())
  {
    if (link == nullptr || skip.count(link->getName()) != 0 || !link->collision_enabled)
      continue;

    const auto tf_it = state.link_transforms.find(link->getName());
    if (tf_it == state.link_transforms.end())
      continue;

    for (const auto& col : link->collision)
    {
      if (col == nullptr || col->geometry == nullptr)
        continue;
      appendShape(venv, *col->geometry, tf_it->second * col->origin);
    }
  }

  venv.sort();
  return venv;
}

template <typename Robot>
class VampOwningStateValidityChecker : public ompl::vamp::VampStateValidityChecker<Robot>
{
public:
  VampOwningStateValidityChecker(const ompl::base::SpaceInformationPtr& si, std::shared_ptr<VampEnv> env)
    : ompl::vamp::VampStateValidityChecker<Robot>(si, *env), env_(std::move(env))
  {
  }

private:
  std::shared_ptr<VampEnv> env_;
};

template <typename Robot>
class VampOwningMotionValidator : public ompl::vamp::VampMotionValidator<Robot>
{
public:
  VampOwningMotionValidator(const ompl::base::SpaceInformationPtr& si, std::shared_ptr<VampEnv> env)
    : ompl::vamp::VampMotionValidator<Robot>(si, *env), env_(std::move(env))
  {
  }

private:
  std::shared_ptr<VampEnv> env_;
};

template <typename Robot>
bool installVamp(ompl::geometric::SimpleSetup& ss, std::shared_ptr<VampEnv> env)
{
  auto si = ss.getSpaceInformation();
  si->setStateValidityChecker(std::make_shared<VampOwningStateValidityChecker<Robot>>(si, env));
  si->setMotionValidator(std::make_shared<VampOwningMotionValidator<Robot>>(si, env));
  CONSOLE_BRIDGE_logInform("OMPL VAMP acceleration enabled for robot '%s' (SIMD width %d)",
                           Robot::name,
                           static_cast<int>(vamp::FloatVectorWidth));
  return true;
}
}  // namespace

bool tryEnableVampAcceleration(ompl::geometric::SimpleSetup& simple_setup,
                               const tesseract::environment::Environment& env,
                               const tesseract::kinematics::JointGroup& manip)
{
  const std::vector<std::string> joints = manip.getJointNames();
  auto simd_env = std::make_shared<VampEnv>(buildWorld(env, manip.getActiveLinkNames()));

  if (jointsMatch<vamp::robots::Panda>(joints))
    return installVamp<vamp::robots::Panda>(simple_setup, std::move(simd_env));
  if (jointsMatch<vamp::robots::UR5>(joints))
    return installVamp<vamp::robots::UR5>(simple_setup, std::move(simd_env));
  if (jointsMatch<vamp::robots::Fetch>(joints))
    return installVamp<vamp::robots::Fetch>(simple_setup, std::move(simd_env));

  CONSOLE_BRIDGE_logWarn("OMPL VAMP requested, but manipulator joints do not match a built-in VAMP robot "
                         "(Panda, UR5, Fetch) in name and order. Falling back to Tesseract collision.");
  return false;
}
}  // namespace tesseract::motion_planners
