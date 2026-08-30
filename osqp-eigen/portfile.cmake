vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gbionics/osqp-eigen
    REF "v${VERSION}"
    SHA512 44047c6336e093a6ab06ffbe621e00c0295bd66f2e8463293dd0be0b13c84040bcf07fbf1a974ca01627a958d7f99503da4a8b7424095802081a0b10a56753af
    HEAD_REF master
)

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")
vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(PACKAGE_NAME OsqpEigen CONFIG_PATH lib/cmake/OsqpEigen)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
