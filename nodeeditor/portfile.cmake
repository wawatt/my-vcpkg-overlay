
vcpkg_download_distfile(
    ARCHIVE 
    URLS "https://codeload.github.com/paceholder/nodeeditor/tar.gz/refs/tags/${VERSION}"
    FILENAME "nodeeditor-${VERSION}.tar.gz"
    SHA512 604b4597c5eb9a2761e287eff4825b6ea6901e6eaea19b61e320064e366ff9f266211fea4f5fd745daac0b312739a8d43697cfdefbaaaf00d3fa55bf8958e5cc  # 先填0，安装后会得到正确值
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
        -DUSE_QT6=OFF 
        # -DBUILD_SHARED_LIBS=OFF
    OPTIONS_DEBUG   
        -DCMAKE_DEBUG_POSTFIX=d
)

vcpkg_cmake_install()
# vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/QtNodes)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/LICENSE.rst" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" COPYONLY)
# vcpkg_fixup_pkgconfig()