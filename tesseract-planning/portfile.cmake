vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tesseract-robotics/tesseract_planning
    REF "${VERSION}"
    SHA512 c028f3292093d183c2e8c5cb93f6cdaa3954038f96f03b24a847d5995f2ca573ac6b0bd05a6d7c299a5761d6b7f95100bf0fd84c2c43a751324167cae8622e63
    HEAD_REF master
    PATCHES
        fix-osqp-target.patch
)

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
