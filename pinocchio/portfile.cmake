# vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stack-of-tasks/pinocchio
    REF "v${VERSION}"
    SHA512 4b41943c42d9971bf71afd4b9491c8faed2f69c844a69f934e2a951ccc3b012139df4cfafa76ae9454078c753bb406befc2e6738a264519152639dea70e305dc
    HEAD_REF main
)

# Download submodules from github manually since vpckg doesn't support submodules natively.
vcpkg_from_github(
    OUT_SOURCE_PATH JRL_CMAKE_MODULES_PATHH
    REPO jrl-umi3218/jrl-cmakemodules
    REF master
    SHA512  a4782b2b845c16638cd5415762d9c69d9ff72059940aae17381c22be7389592719238b15aaabdf12f6a27294a1a43effaa4153519256899c4d5911b7bc34760b
    HEAD_REF master
)
file(REMOVE_RECURSE "${SOURCE_PATH}/cmake")
# Copy the submodules to the right place
file(COPY "${JRL_CMAKE_MODULES_PATHH}/" DESTINATION "${SOURCE_PATH}/cmake")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS_RELEASE -DBUILD_WITH_OPENMP_SUPPORT=ON -DBUILD_PYTHON_INTERFACE=OFF -DBUILD_TESTING=OFF -DBUILD_WITH_COLLISION_SUPPORT=ON 
    OPTIONS_DEBUG   -DBUILD_WITH_OPENMP_SUPPORT=ON -DBUILD_PYTHON_INTERFACE=OFF -DBUILD_TESTING=OFF -DBUILD_WITH_COLLISION_SUPPORT=ON -DCMAKE_DEBUG_POSTFIX=d
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/pinocchio)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
# file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" COPYONLY)
# vcpkg_fixup_pkgconfig()