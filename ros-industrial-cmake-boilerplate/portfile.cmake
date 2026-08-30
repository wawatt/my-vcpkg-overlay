# CMake-module package (no compiled libraries).
set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ros-industrial/ros_industrial_cmake_boilerplate
    REF "${VERSION}"
    SHA512 7b2c2bee923f50bfd7a19b51be5a3483f6efd4ecc57998fff6ca0185c1ac7bbd4287aa13d322116a4c7baba28d1de1a0b61540ab70443291947339a379b7f1ac
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DRICB_PACKAGE=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(
    PACKAGE_NAME ros_industrial_cmake_boilerplate
    CONFIG_PATH lib/cmake/ros_industrial_cmake_boilerplate
)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug"
    "${CURRENT_PACKAGES_DIR}/lib"
    "${CURRENT_PACKAGES_DIR}/share/ament_index"
    "${CURRENT_PACKAGES_DIR}/share/ros_industrial_cmake_boilerplate/hook"
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
