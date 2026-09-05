#ifndef TESSERACT_MOTION_PLANNERS_OMPL_VAMP_SUPPORT_H
#define TESSERACT_MOTION_PLANNERS_OMPL_VAMP_SUPPORT_H

#include <memory>
#include <string>
#include <vector>

namespace ompl::geometric
{
class SimpleSetup;
}

namespace tesseract::environment
{
class Environment;
}

namespace tesseract::kinematics
{
class JointGroup;
}

namespace tesseract::motion_planners
{
/**
 * @brief Enable OMPL VAMP SIMD collision checking when the manipulator matches a
 * built-in VAMP robot (Panda, UR5, Fetch) with the same joint names and order.
 *
 * World collision geometry that is not on the manipulator's active links is converted
 * to VAMP spheres/boxes/cylinders/capsules. Meshes and other types are skipped.
 *
 * Robot self-collision uses VAMP's compiled sphere model, not Tesseract meshes.
 *
 * @return true if VAMP validators were installed on @p simple_setup
 */
bool tryEnableVampAcceleration(ompl::geometric::SimpleSetup& simple_setup,
                               const tesseract::environment::Environment& env,
                               const tesseract::kinematics::JointGroup& manip);
}  // namespace tesseract::motion_planners

#endif  // TESSERACT_MOTION_PLANNERS_OMPL_VAMP_SUPPORT_H
