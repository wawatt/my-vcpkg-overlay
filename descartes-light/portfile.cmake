vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO swri-robotics/descartes_light
    REF "${VERSION}"
    SHA512 31216a80caba6875930322815919f13bf1ded133072fc5ff9709f3f230913e68c3db9b62c802814180cc9e875005e0005b08b47e3e449a2bb0888c331d9fc738
    HEAD_REF master
)

# Upstream calls find_package() before project(); pass the installed prefix.
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/descartes_light"
    OPTIONS
        "-DCMAKE_PREFIX_PATH=${CURRENT_INSTALLED_DIR}"
        -DDESCARTES_ENABLE_TESTING=OFF
        -DDESCARTES_PACKAGE=OFF
        -DBUILD_TESTING=OFF
    MAYBE_UNUSED_VARIABLES
        DESCARTES_ENABLE_TESTING
        DESCARTES_PACKAGE
        BUILD_TESTING
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(
    PACKAGE_NAME descartes_light
    CONFIG_PATH lib/cmake/descartes_light
)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/share/ament_index"
    "${CURRENT_PACKAGES_DIR}/share/descartes_light/hook"
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.Apache-2.0")
