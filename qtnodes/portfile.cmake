
vcpkg_download_distfile(
    ARCHIVE 
    URLS "https://codeload.github.com/paceholder/nodeeditor/tar.gz/refs/tags/${VERSION}"
    FILENAME "nodeeditor-${VERSION}.tar.gz"
    SHA512 3254f8683b458c72221d9416240df09a6443bc12543a6ac83c400958ed975139b39d64a07e913a47b41d71b76a225233c8dc8c245d2453e141c8ed4d88bc1507  # 先填0，安装后会得到正确值
)

# 解压下载的文件
vcpkg_extract_source_archive(
    SOURCE_PATH ARCHIVE "${ARCHIVE}"
)

# vcpkg_from_github(
#     OUT_SOURCE_PATH SOURCE_PATH
#     REPO placeholder/nodeeditor
#     REF "${VERSION}"
#     SHA512 0
#     HEAD_REF master
# )

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DUSE_QT6=ON
        -DBUILD_SHARED_LIBS=OFF
        -DCMAKE_CXX_STANDARD=17
    OPTIONS_DEBUG   
        -DBUILD_DEBUG_POSTFIX_D=ON
)

vcpkg_cmake_install()
# vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/QtNodes)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/LICENSE.rst" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" COPYONLY)
# vcpkg_fixup_pkgconfig()