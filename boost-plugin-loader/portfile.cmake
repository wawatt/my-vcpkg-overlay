vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tesseract-robotics/boost_plugin_loader
    REF "${VERSION}"
    SHA512 40e8bb199bc980a8eb5f463bfebf1422fc795ea3895213e754045b89834b207e338cf1959f15f5782ea5ba089ea90bc333a28f513b9b1f512879300ef5d4b8b6
    HEAD_REF main
    PATCHES
        skip-examples.patch
)

# Upstream calls find_package() before project(); the vcpkg toolchain is not
# loaded yet, so pass the installed prefix on the command line.
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DCMAKE_PREFIX_PATH=${CURRENT_INSTALLED_DIR}"
        -DBUILD_TESTING=OFF
        -DBUILD_EXAMPLES=OFF
        -DENABLE_CLANG_TIDY=OFF
        -DENABLE_CODE_COVERAGE=OFF
        -DENABLE_CPACK=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(
    PACKAGE_NAME boost_plugin_loader
    CONFIG_PATH lib/cmake/boost_plugin_loader
)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/share/ament_index"
    "${CURRENT_PACKAGES_DIR}/share/boost_plugin_loader/hook"
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.Apache-2.0")
