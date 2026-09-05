# Windows-only overlay ompl: OMPL 2.0.2 (ompl/ompl main) + win-branch MSVC/VAMP patches.
# Replaces registry ompl 1.7.0. MSVC default is a static library; VAMP is header-only plus simdxorshift.
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
vcpkg_buildpath_length_warning(37)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ompl/ompl
    REF 48552087421d86c0def3ace22e8733dc7fc75601
    SHA512 2a01ad2d40e902fcdb0e6a83ca2d3f553ba86b34782e4e28d6996207e1c7b361891f7f2d2c0f30d37d1e101b4326cf4ebbb4bb87b4c8aa4382f1c1306a9d09ac
    HEAD_REF main
    PATCHES
        0001-ompl-msvc-vamp.patch
)

# VAMP is a git submodule; apply the win-branch MSVC patch then drop it into external/vamp.
vcpkg_from_github(
    OUT_SOURCE_PATH VAMP_SOURCE_PATH
    REPO KavrakiLab/vamp
    REF aa4f4b5346417db5eecf61e4443f06655c463d3e
    SHA512 bbf05c110a0c8862505d5d99265d713938895444113ee89c1f783bba8795f4f33cdb42483e054a0e9276e9e0027250828f40b88e5e895878212d1a78a8b1b4ca
    HEAD_REF main
    PATCHES
        0002-vamp-submodule-msvc.patch
)
file(WRITE "${VAMP_SOURCE_PATH}/cmake/FetchInitCPM.cmake" [[
if(DEFINED VAMP_CPM_FILE AND EXISTS "${VAMP_CPM_FILE}")
  file(MAKE_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/cmake")
  configure_file("${VAMP_CPM_FILE}" "${CMAKE_CURRENT_BINARY_DIR}/cmake/CPM.cmake" COPYONLY)
else()
  file(
    DOWNLOAD
    https://github.com/cpm-cmake/CPM.cmake/releases/download/v0.40.1/CPM.cmake
    ${CMAKE_CURRENT_BINARY_DIR}/cmake/CPM.cmake
    EXPECTED_HASH SHA256=117cbf2711572f113bab262933eb5187b08cfc06dce0714a1ee94f2183ddc3ec
  )
endif()
set(CPM_USE_LOCAL_PACKAGES ON)
include(${CMAKE_CURRENT_BINARY_DIR}/cmake/CPM.cmake)
]])
vcpkg_replace_string("${VAMP_SOURCE_PATH}/cmake/Dependencies.cmake"
    [[CPMAddPackage("gh:kavrakilab/nigh#97130999440647c204e0265d05a997dbd8da4e70")]]
[[if(DEFINED VAMP_NIGH_SOURCE_DIR AND EXISTS "${VAMP_NIGH_SOURCE_DIR}")
  CPMAddPackage(NAME nigh SOURCE_DIR "${VAMP_NIGH_SOURCE_DIR}")
else()
  CPMAddPackage("gh:kavrakilab/nigh#97130999440647c204e0265d05a997dbd8da4e70")
endif()]]
)
vcpkg_replace_string("${VAMP_SOURCE_PATH}/cmake/Dependencies.cmake"
    [[CPMAddPackage("gh:orlp/pdqsort#b1ef26a55cdb60d236a5cb199c4234c704f46726")]]
[[if(DEFINED VAMP_PDQSORT_SOURCE_DIR AND EXISTS "${VAMP_PDQSORT_SOURCE_DIR}")
  CPMAddPackage(NAME pdqsort SOURCE_DIR "${VAMP_PDQSORT_SOURCE_DIR}")
else()
  CPMAddPackage("gh:orlp/pdqsort#b1ef26a55cdb60d236a5cb199c4234c704f46726")
endif()]]
)
vcpkg_replace_string("${VAMP_SOURCE_PATH}/cmake/Dependencies.cmake"
    [[CPMAddPackage("gh:lemire/SIMDxorshift#857c1a01df53cf1ee1ae8db3238f0ef42ef8e490")]]
[[if(DEFINED VAMP_SIMDXORSHIFT_SOURCE_DIR AND EXISTS "${VAMP_SIMDXORSHIFT_SOURCE_DIR}")
  CPMAddPackage(NAME SIMDxorshift SOURCE_DIR "${VAMP_SIMDXORSHIFT_SOURCE_DIR}")
else()
  CPMAddPackage("gh:lemire/SIMDxorshift#857c1a01df53cf1ee1ae8db3238f0ef42ef8e490")
endif()]]
)
file(REMOVE_RECURSE "${SOURCE_PATH}/external/vamp")
file(COPY "${VAMP_SOURCE_PATH}/" DESTINATION "${SOURCE_PATH}/external/vamp")

# VAMP pulls these via CPM at configure time; vendor them so configure can run offline.
vcpkg_from_github(
    OUT_SOURCE_PATH NIGH_SOURCE_PATH
    REPO kavrakilab/nigh
    REF 97130999440647c204e0265d05a997dbd8da4e70
    SHA512 100ab6aea5a43430ef7ac4e124744736c5c62ef9d0b8de117a83d55f90efeb73d9151e96a653804a234eb51bec3dfce34b23847f2fc27cca112ab92ae1933e89
    HEAD_REF master
)
vcpkg_from_github(
    OUT_SOURCE_PATH PDQSORT_SOURCE_PATH
    REPO orlp/pdqsort
    REF b1ef26a55cdb60d236a5cb199c4234c704f46726
    SHA512 3ff456f5087fdce0547ce3f0ae1a2797f1e086b21afd2e556e6a3a19988be0637133bcd25308e1e7592fd1edd1ce4dc90865f4e8fb4ed17574c4d601c659ed2b
    HEAD_REF master
)
vcpkg_from_github(
    OUT_SOURCE_PATH SIMDXORSHIFT_SOURCE_PATH
    REPO lemire/SIMDxorshift
    REF 857c1a01df53cf1ee1ae8db3238f0ef42ef8e490
    SHA512 b795f617f635b78feb158880d2f4d77ebd76c25429032549e7a9dc47b284690d0a36e65be6962693b463e451a0ada31edfd860ce2e396263e12be00fa469d507
    HEAD_REF master
)
vcpkg_download_distfile(CPM_CMAKE
    URLS "https://github.com/cpm-cmake/CPM.cmake/releases/download/v0.40.1/CPM.cmake"
    FILENAME "CPM-0.40.1.cmake"
    SHA512 177676cd99c06ba69ff21fdefc26499b9523b4792959d896ef13182e3bd1443559cbef741952d4dc51372066badbafa320406f6c9f60400ed82924acd834568c
)

# Official ports/ompl: drop bundled Find*.cmake so vcpkg packages win; stub Python.
file(GLOB _ompl_find_modules "${SOURCE_PATH}/CMakeModules/Find*.cmake")
if(_ompl_find_modules)
    file(REMOVE ${_ompl_find_modules})
endif()
file(COPY "${CMAKE_CURRENT_LIST_DIR}/FindPython.cmake" DESTINATION "${SOURCE_PATH}/CMakeModules")
# Do not compile Python bindings (OMPL nanobind or VAMP).
file(REMOVE_RECURSE
    "${SOURCE_PATH}/py-bindings"
    "${SOURCE_PATH}/external/nanobind"
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DOMPL_VERSIONED_INSTALL=OFF
        -DOMPL_BUILD_SHARED=OFF
        -DOMPL_BUILD_DEMOS=OFF
        -DOMPL_BUILD_TESTS=OFF
        -DOMPL_BUILD_PYTHON_BINDINGS=OFF
        -DOMPL_BUILD_VAMP=ON
        -DVAMP_PORTABLE_BUILD=ON
        -DVAMP_BUILD_PYTHON_BINDINGS=OFF
        -DVAMP_LTO=OFF
        "-DVAMP_CPM_FILE=${CPM_CMAKE}"
        "-DVAMP_NIGH_SOURCE_DIR=${NIGH_SOURCE_PATH}"
        "-DVAMP_PDQSORT_SOURCE_DIR=${PDQSORT_SOURCE_PATH}"
        "-DVAMP_SIMDXORSHIFT_SOURCE_DIR=${SIMDXORSHIFT_SOURCE_PATH}"
        -DR_EXEC=R_EXEC-NOTFOUND
        -DCMAKE_DISABLE_FIND_PACKAGE_Doxygen=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_spot=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_Triangle=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_Python=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_Python3=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_flann=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_castxml=ON
    MAYBE_UNUSED_VARIABLES
        OMPL_BUILD_SHARED
        VAMP_LTO
        R_EXEC
        CMAKE_DISABLE_FIND_PACKAGE_castxml
        CMAKE_DISABLE_FIND_PACKAGE_Python3
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH share/ompl/cmake)
if(EXISTS "${CURRENT_PACKAGES_DIR}/share/cmake/vamp")
    vcpkg_cmake_config_fixup(PACKAGE_NAME vamp CONFIG_PATH share/cmake/vamp)
endif()

# VAMP headers include nigh; pdqsort.h is already provided by seacas in this tree.
file(COPY "${NIGH_SOURCE_PATH}/src/nigh" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/share/man"
    "${CURRENT_PACKAGES_DIR}/share/ompl/demos"
    "${CURRENT_PACKAGES_DIR}/share/ament_index"
    "${CURRENT_PACKAGES_DIR}/share/cmake"
    "${CURRENT_PACKAGES_DIR}/lib/cmake"
    "${CURRENT_PACKAGES_DIR}/debug/lib/cmake"
    "${CURRENT_PACKAGES_DIR}/bin"
    "${CURRENT_PACKAGES_DIR}/debug/bin"
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
