vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tesseract-robotics/tesseract_planning
    REF "${VERSION}"
    SHA512 c028f3292093d183c2e8c5cb93f6cdaa3954038f96f03b24a847d5995f2ca573ac6b0bd05a6d7c299a5761d6b7f95100bf0fd84c2c43a751324167cae8622e63
    HEAD_REF master
    PATCHES
        fix-osqp-target.patch
        use-ompl-config-target.patch
)

# VAMP-accelerated OMPL: extra sources plus profile/CMake hooks.
file(COPY "${CMAKE_CURRENT_LIST_DIR}/files/vamp_support.h"
     DESTINATION "${SOURCE_PATH}/motion_planners/ompl/include/tesseract/motion_planners/ompl")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/files/vamp_support.cpp"
     DESTINATION "${SOURCE_PATH}/motion_planners/ompl/src")
vcpkg_replace_string("${SOURCE_PATH}/motion_planners/ompl/CMakeLists.txt"
    "    src/weighted_real_vector_state_sampler.cpp)"
    "    src/weighted_real_vector_state_sampler.cpp
    src/vamp_support.cpp)")
vcpkg_replace_string("${SOURCE_PATH}/motion_planners/ompl/CMakeLists.txt"
    [[target_include_directories(motion_planners_ompl SYSTEM PUBLIC ${OMPL_INCLUDE_DIRS})]]
    [[target_include_directories(motion_planners_ompl SYSTEM PUBLIC ${OMPL_INCLUDE_DIRS})
if(MSVC)
  set_source_files_properties(src/vamp_support.cpp PROPERTIES COMPILE_OPTIONS "/arch:AVX2;/permissive-;/bigobj")
endif()
target_link_libraries(motion_planners_ompl PRIVATE simdxorshift)]])
vcpkg_replace_string("${SOURCE_PATH}/motion_planners/ompl/include/tesseract/motion_planners/ompl/profile/ompl_real_vector_move_profile.h"
    "  /** @brief The collision check configuration */
  tesseract::collision::CollisionCheckConfig collision_check_config;"
    "  /** @brief The collision check configuration */
  tesseract::collision::CollisionCheckConfig collision_check_config;

  /**
   * @brief Use OMPL VAMP SIMD collision checking when the manipulator matches a
   * built-in VAMP robot (Panda, UR5, Fetch) with the same joint names and order.
   * Falls back to Tesseract collision if the robot is not supported.
   */
  bool use_vamp{ false };")
vcpkg_replace_string("${SOURCE_PATH}/motion_planners/ompl/src/profile/ompl_real_vector_move_profile.cpp"
    "#include <tesseract/motion_planners/ompl/profile/ompl_real_vector_move_profile.h>"
    "#include <tesseract/motion_planners/ompl/profile/ompl_real_vector_move_profile.h>
#include <tesseract/motion_planners/ompl/vamp_support.h>")
vcpkg_replace_string("${SOURCE_PATH}/motion_planners/ompl/src/profile/ompl_real_vector_move_profile.cpp"
    "    if (YAML::Node n = config[\"collision_check_config\"])
      collision_check_config = n.as<tesseract::collision::CollisionCheckConfig>();"
    "    if (YAML::Node n = config[\"collision_check_config\"])
      collision_check_config = n.as<tesseract::collision::CollisionCheckConfig>();

    if (YAML::Node n = config[\"use_vamp\"])
      use_vamp = n.as<bool>();")
vcpkg_replace_string("${SOURCE_PATH}/motion_planners/ompl/src/profile/ompl_real_vector_move_profile.cpp"
    "  // Setup state validators
  auto csvc = std::make_shared<CompoundStateValidator>();
  ompl::base::StateValidityCheckerPtr svc_without_collision =
      createStateValidator(*simple_setup, env, manip, state_extractor);
  if (svc_without_collision != nullptr)
    csvc->addStateValidator(svc_without_collision);

  auto svc_collision = createCollisionStateValidator(*simple_setup, env, manip, state_extractor);
  if (svc_collision != nullptr)
    csvc->addStateValidator(std::move(svc_collision));

  simple_setup->setStateValidityChecker(csvc);

  // Setup motion validation (i.e. collision checking)
  auto mv = createMotionValidator(*simple_setup, env, manip, state_extractor, svc_without_collision);
  if (mv != nullptr)
    simple_setup->getSpaceInformation()->setMotionValidator(std::move(mv));"
    "  const bool vamp_on = use_vamp && tryEnableVampAcceleration(*simple_setup, *env, *manip);

  if (!vamp_on)
  {
    // Setup state validators
    auto csvc = std::make_shared<CompoundStateValidator>();
    ompl::base::StateValidityCheckerPtr svc_without_collision =
        createStateValidator(*simple_setup, env, manip, state_extractor);
    if (svc_without_collision != nullptr)
      csvc->addStateValidator(svc_without_collision);

    auto svc_collision = createCollisionStateValidator(*simple_setup, env, manip, state_extractor);
    if (svc_collision != nullptr)
      csvc->addStateValidator(std::move(svc_collision));

    simple_setup->setStateValidityChecker(csvc);

    // Setup motion validation (i.e. collision checking)
    auto mv = createMotionValidator(*simple_setup, env, manip, state_extractor, svc_without_collision);
    if (mv != nullptr)
      simple_setup->getSpaceInformation()->setMotionValidator(std::move(mv));
  }")
vcpkg_replace_string("${SOURCE_PATH}/motion_planners/ompl/src/profile/ompl_real_vector_move_profile.cpp"
    "  equal &= (collision_check_config == rhs.collision_check_config);
  return equal;"
    "  equal &= (collision_check_config == rhs.collision_check_config);
  equal &= (use_vamp == rhs.use_vamp);
  return equal;")
vcpkg_replace_string("${SOURCE_PATH}/motion_planners/ompl/include/tesseract/motion_planners/ompl/cereal_serialization.h"
    "  ar(cereal::make_nvp(\"collision_check_config\", obj.collision_check_config));
}"
    "  ar(cereal::make_nvp(\"collision_check_config\", obj.collision_check_config));
  ar(cereal::make_nvp(\"use_vamp\", obj.use_vamp));
}")

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        ompl         TESSERACT_BUILD_OMPL
        descartes    TESSERACT_BUILD_DESCARTES
        trajopt      TESSERACT_BUILD_TRAJOPT
        trajopt-ifopt TESSERACT_BUILD_TRAJOPT_IFOPT
        ruckig       TESSERACT_BUILD_RUCKIG
        taskflow     TESSERACT_BUILD_TASK_COMPOSER_TASKFLOW
)

# Upstream calls find_package() before project(); pass the installed prefix.
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        "-DCMAKE_PREFIX_PATH=${CURRENT_INSTALLED_DIR}"
        "-Dtesseract_DIR=${CURRENT_INSTALLED_DIR}/share/tesseract-robotics"
        -DTESSERACT_ENABLE_TESTING=OFF
        -DTESSERACT_ENABLE_EXAMPLES=OFF
        -DTESSERACT_ENABLE_BENCHMARKING=OFF
        -DTESSERACT_ENABLE_CLANG_TIDY=OFF
        -DTESSERACT_ENABLE_CODE_COVERAGE=OFF
        -DTESSERACT_PACKAGE=OFF
        -DTESSERACT_BUILD_TASK_COMPOSER_PLANNING=ON
        -DBUILD_IPOPT=OFF
        -DBUILD_SNOPT=OFF
    MAYBE_UNUSED_VARIABLES
        BUILD_IPOPT
        BUILD_SNOPT
        TESSERACT_ENABLE_BENCHMARKING
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_copy_tools(TOOL_NAMES tesseract_task_composer_validate_config AUTO_CLEAN)
vcpkg_cmake_config_fixup(PACKAGE_NAME tesseract_planning CONFIG_PATH lib/cmake/tesseract_planning)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/share/ament_index"
    "${CURRENT_PACKAGES_DIR}/share/tesseract_planning/hook"
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/tesseract-planning-config.cmake"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
