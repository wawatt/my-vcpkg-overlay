vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ros-industrial-consortium/trajopt_ros
    REF "${VERSION}"
    SHA512 497c96711a7005873224afbfe2db84cf6c2a5b965c759d5cf268acda90d6c97544b6ed2c93c7e792e4c70a73d19088d2dc1b6c6ba11b51b5a5ec73f5f2b7db9d
    HEAD_REF master
    PATCHES
        fix-jsoncpp-alias.patch
)

# trajopt_ros is a colcon workspace of CMake packages. Build them in dependency
# order into the same prefix so later packages can find earlier ones.
# Skip trajopt_ext/{osqp,osqp_eigen,qpoases}: those CMakeLists git-clone during
# configure. osqp and osqp-eigen come from overlay ports; qpOASES is optional.
set(TRAJOPT_SUBDIRS
    trajopt_common
    trajopt_ext/vhacd
    trajopt_ifopt
    trajopt_sco
    trajopt
    trajopt_optimizers/trajopt_sqp
)

set(prefix_path "${CURRENT_INSTALLED_DIR};${CURRENT_PACKAGES_DIR}")

foreach(subdir IN LISTS TRAJOPT_SUBDIRS)
    string(REPLACE "/" "-" logname "${subdir}")
    message(STATUS "Configuring trajopt package ${subdir}")
    unset(Z_VCPKG_CMAKE_GENERATOR CACHE)
    vcpkg_cmake_configure(
        SOURCE_PATH "${SOURCE_PATH}/${subdir}"
        LOGFILE_BASE "config-${TARGET_TRIPLET}-${logname}"
        OPTIONS
            "-DCMAKE_PREFIX_PATH=${prefix_path}"
            -DTRAJOPT_ENABLE_TESTING=OFF
            -DTRAJOPT_PACKAGE=OFF
            -DTRAJOPT_BUILD_qpOASES=OFF
            -DBUILD_TESTING=OFF
            -DBUILD_IPOPT=OFF
            -DBUILD_SNOPT=OFF
            -DNO_OPENCL=ON
        MAYBE_UNUSED_VARIABLES
            TRAJOPT_ENABLE_TESTING
            TRAJOPT_PACKAGE
            TRAJOPT_BUILD_qpOASES
            BUILD_TESTING
            BUILD_IPOPT
            BUILD_SNOPT
            NO_OPENCL
    )
    vcpkg_cmake_install()
endforeach()

vcpkg_copy_pdbs()

file(GLOB trajopt_cmake_dirs "${CURRENT_PACKAGES_DIR}/lib/cmake/*")
foreach(cmake_dir IN LISTS trajopt_cmake_dirs)
    get_filename_component(pkg_name "${cmake_dir}" NAME)
    vcpkg_cmake_config_fixup(
        PACKAGE_NAME "${pkg_name}"
        CONFIG_PATH "lib/cmake/${pkg_name}"
        DO_NOT_DELETE_PARENT_CONFIG_PATH
    )
endforeach()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/cmake" "${CURRENT_PACKAGES_DIR}/debug/lib/cmake")

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/share/ament_index"
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/trajopt/LICENSE" "${SOURCE_PATH}/trajopt_sco/LICENSE")
