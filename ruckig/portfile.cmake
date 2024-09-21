vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pantor/ruckig
    REF "v${VERSION}"
    SHA512 cd8e31d4cc41cf90a23095f39f58e7139ac12a34c7699f3274c6389916cbed56a6e8627facaf34e5a888d43b78e43cb01dce1cd1ef45201652d3ded917a80075  # This is a temporary value. We will modify this value in the next section.
    HEAD_REF main
)


vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS_RELEASE -DBUILD_CLOUD_CLIENT=ON -DBUILD_EXAMPLES=OFF -DBUILD_TESTS=OFF
    OPTIONS_DEBUG -DBUILD_CLOUD_CLIENT=ON -DBUILD_EXAMPLES=OFF -DBUILD_TESTS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME "ruckig")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(COPY "${SOURCE_PATH}/third_party/doctest" DESTINATION "${CURRENT_PACKAGES_DIR}/include/ruckig")
file(COPY "${SOURCE_PATH}/third_party/httplib" DESTINATION "${CURRENT_PACKAGES_DIR}/include/ruckig")
file(COPY "${SOURCE_PATH}/third_party/nlohmann" DESTINATION "${CURRENT_PACKAGES_DIR}/include/ruckig")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" COPYONLY)