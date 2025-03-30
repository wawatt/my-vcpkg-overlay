# vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO humanoid-path-planner/hpp-fcl
    REF "v${VERSION}"
    SHA512 3391563c55864d8c22d15b81b45cb5bc24408e1c01863cebc2909df3b9d31a0738179eae97c475f11b31189952aa158c0fc1f7d5eab32f954eedb4bcdec9170c
    HEAD_REF main
)

# Download submodules from github manually since vpckg doesn't support submodules natively.
vcpkg_from_github(
    OUT_SOURCE_PATH JRL_CMAKE_MODULES_PATHH
    REPO jrl-umi3218/jrl-cmakemodules
    REF master
    SHA512 a4782b2b845c16638cd5415762d9c69d9ff72059940aae17381c22be7389592719238b15aaabdf12f6a27294a1a43effaa4153519256899c4d5911b7bc34760b
    HEAD_REF master
)
# file(REMOVE_RECURSE "${SOURCE_PATH}/cmake")
# Copy the submodules to the right place
file(COPY "${JRL_CMAKE_MODULES_PATHH}/" DESTINATION "${SOURCE_PATH}/cmake")
# vcpkg_from_github(
#     OUT_SOURCE_PATH qhull_PATHH
#     REPO qhull/qhull
#     REF master
#     SHA512 3e7108b3950eb7ba06c753355148e0eb000f28f1e7bb24069cea400deba547bc5ce9dd8c44a0252441b16298a1a84bdae778dcf0a1b74c433f1ed3a58e2d7045
#     HEAD_REF master
# )
# file(COPY "${qhull_PATHH}/" DESTINATION "${SOURCE_PATH}/third-parties/qhull")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS_RELEASE -DBUILD_PYTHON_INTERFACE=OFF -DBUILD_TESTING=OFF
    OPTIONS_DEBUG   -DBUILD_PYTHON_INTERFACE=OFF -DBUILD_TESTING=OFF -DCMAKE_DEBUG_POSTFIX=d
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/hpp-fcl)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" COPYONLY)
vcpkg_fixup_pkgconfig()