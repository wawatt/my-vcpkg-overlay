vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO hungpham2511/toppra
    REF "v${VERSION}"
    SHA512 0cc2f647c0676218a7b8466951038dbd8a11a27afc31557d73a10efd811dbba9cb1ef4440463c57d2926bcf3bec1fc71634cc67c172a7d9fd9af549798b0061f  # This is a temporary value. We will modify this value in the next section.
    HEAD_REF develop
)


vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/cpp"
    OPTIONS 
        -DPYTHON_BINDINGS=OFF 
        -DBUILD_SHARED_LIBS=OFF 
        -DBUILD_TESTS=OFF
    OPTIONS_DEBUG   
        -DCMAKE_DEBUG_POSTFIX=d
        -DTOPPRA_DEBUG_ON=ON
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/toppra)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" COPYONLY)