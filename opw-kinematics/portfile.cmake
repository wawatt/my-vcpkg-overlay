vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Jmeyer1292/opw_kinematics
    REF "${VERSION}"
    SHA512 0b59753487b53983c94815ae59468e037463208e2f34d6c8a42867bf3d2d6442644cbf049877c00be50c7757e5982e86806d19715b4ca7a7bedec1f1617770bd
    HEAD_REF master
    PATCHES
        skip-node.patch
)

# Upstream calls find_package() before project(); the vcpkg toolchain is not
# loaded yet, so pass the installed prefix on the command line.
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DCMAKE_PREFIX_PATH=${CURRENT_INSTALLED_DIR}"
        -DOPW_ENABLE_TESTING=OFF
        -DOPW_PACKAGE=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(
    PACKAGE_NAME opw_kinematics
    CONFIG_PATH lib/cmake/opw_kinematics
)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug"
    "${CURRENT_PACKAGES_DIR}/lib"
    "${CURRENT_PACKAGES_DIR}/share/ament_index"
    "${CURRENT_PACKAGES_DIR}/share/opw_kinematics/hook"
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
