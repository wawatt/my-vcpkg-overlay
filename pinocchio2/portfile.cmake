# vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stack-of-tasks/pinocchio
    REF "v${VERSION}"
    SHA512 4b41943c42d9971bf71afd4b9491c8faed2f69c844a69f934e2a951ccc3b012139df4cfafa76ae9454078c753bb406befc2e6738a264519152639dea70e305dc
    HEAD_REF develop
)

# Download submodules from github manually since vpckg doesn't support submodules natively.
vcpkg_from_github(
    OUT_SOURCE_PATH JRL_CMAKE_MODULES_PATHH
    REPO jrl-umi3218/jrl-cmakemodules
    REF 88f509ad78a1630108c54d304ba379b8021a12d4
    SHA512  df7cbf22623d15473184762e2b601932624ae4e8c6541937e6067e82c4ef617c83985fcf370848c7046055030686f99cf75440b48335c029f8767495ca820c28
    HEAD_REF master
)
file(REMOVE_RECURSE "${SOURCE_PATH}/cmake")
# Copy the submodules to the right place
file(COPY "${JRL_CMAKE_MODULES_PATHH}/" DESTINATION "${SOURCE_PATH}/cmake")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_WITH_OPENMP_SUPPORT=ON 
        -DBUILD_WITH_EXTRA_SUPPORT=ON 
        -DBUILD_PYTHON_INTERFACE=OFF 
        -DBUILD_WITH_CPPAD_SUPPORT=ON
        -DBUILD_TESTING=OFF 
        -DBUILD_WITH_COLLISION_SUPPORT=ON 
        -DBUILDING_ROS2_PACKAGE=OFF
    OPTIONS_DEBUG   
        -DCMAKE_DEBUG_POSTFIX=d
)

vcpkg_cmake_install()
# vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/pinocchio)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
# file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" COPYONLY)
# vcpkg_fixup_pkgconfig()