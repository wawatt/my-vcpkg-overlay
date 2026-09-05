vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tesseract-robotics/tesseract
    REF "${VERSION}"
    SHA512 bf3d9519409f34c10e9976a0aa42caab968180a20e1bc1a756f8786c4263221e464e694d4ab2cf7dab4bcec649c48cfeef4bfd807c766c72df9fc59751eb1b19
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        fcl    TESSERACT_BUILD_FCL
        vhacd  TESSERACT_BUILD_VHACD
        kdl    TESSERACT_BUILD_KDL
        opw    TESSERACT_BUILD_OPW
        ikfast TESSERACT_BUILD_IKFAST
        ur     TESSERACT_BUILD_UR
)

# Upstream calls find_package() before project(); the vcpkg toolchain is not
# loaded yet, so pass the installed prefix on the command line.
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        "-DCMAKE_PREFIX_PATH=${CURRENT_INSTALLED_DIR}"
        -DTESSERACT_ENABLE_TESTING=OFF
        -DTESSERACT_ENABLE_EXAMPLES=OFF
        -DTESSERACT_ENABLE_BENCHMARKING=OFF
        -DTESSERACT_ENABLE_CLANG_TIDY=OFF
        -DTESSERACT_ENABLE_CODE_COVERAGE=OFF
        -DTESSERACT_PACKAGE=OFF
        -DTESSERACT_BUILD_TEST_SUITE=OFF
        -DTESSERACT_BUILD_GZ_VISUALIZATION=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(PACKAGE_NAME tesseract CONFIG_PATH lib/cmake/tesseract)

# opencv4[contrib] also installs TesseractConfig.cmake into share/tesseract.
# On Windows, find_package(tesseract) matches that file (case-insensitive)
# before tesseract-config.cmake. Keep this port's CMake files here instead.
file(GLOB tess_cmake_files "${CURRENT_PACKAGES_DIR}/share/tesseract/*.cmake")
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(COPY ${tess_cmake_files} DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(REMOVE ${tess_cmake_files})
if(NOT VCPKG_BUILD_TYPE)
    file(GLOB tess_cmake_dbg "${CURRENT_PACKAGES_DIR}/debug/share/tesseract/*.cmake")
    if(tess_cmake_dbg)
        file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/share/${PORT}")
        file(COPY ${tess_cmake_dbg} DESTINATION "${CURRENT_PACKAGES_DIR}/debug/share/${PORT}")
        file(REMOVE ${tess_cmake_dbg})
    endif()
endif()
file(WRITE "${CURRENT_PACKAGES_DIR}/share/${PORT}/tesseractConfig.cmake"
    "include(\"\${CMAKE_CURRENT_LIST_DIR}/tesseract-config.cmake\")\n")

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/share/ament_index"
    "${CURRENT_PACKAGES_DIR}/share/tesseract/hook"
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/tesseract-robotics-config.cmake"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
