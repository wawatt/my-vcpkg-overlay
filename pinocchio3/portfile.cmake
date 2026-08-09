# vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stack-of-tasks/pinocchio
    REF "v${VERSION}"
    SHA512 e2032ddeac9ca45c7272fed3c06dd060e2eef0f82dfa9dc3164874c52ace118c65e7d7c6e09c429a73158d425dc736a12e831a6fa2a02910d0d297ebcb7751e7
    HEAD_REF develop
    PATCHES
        fix001-casadi-CMakeLists-txt.patch
        fix002-casadi-src-CMakeLists-txt.patch
        fix003-casadi-bindings-python-CMakeLists-txt.patch
        fix004-unittest-casadi-CMakeLists-txt.patch
    # PATCHES IS UTF8
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
        # -DBUILD_WITH_CASADI_SUPPORT=ON 
        -DBUILD_WITH_EXTRA_SUPPORT=ON 
        -DBUILD_WITH_OPENMP_SUPPORT=ON 
        -DBUILD_PYTHON_INTERFACE=OFF 
        -DBUILD_WITH_AUTODIFF_SUPPORT=ON
        -DBUILD_TESTING=OFF 
        -DBUILD_WITH_COLLISION_SUPPORT=ON 
        -DBUILDING_ROS2_PACKAGE=OFF
    OPTIONS_RELEASE
        -DCMAKE_RELEASE_POSTFIX=3
    OPTIONS_DEBUG
        -DCMAKE_DEBUG_POSTFIX=3d
)

vcpkg_cmake_install()
# vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/pinocchio)
vcpkg_copy_pdbs()

file(COPY ${CURRENT_PACKAGES_DIR}/share/pinocchio/ DESTINATION ${CURRENT_PACKAGES_DIR}/share/pinocchio3)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/pinocchio")
file(RENAME ${CURRENT_PACKAGES_DIR}/lib/pkgconfig/pinocchio.pc ${CURRENT_PACKAGES_DIR}/lib/pkgconfig/pinocchio3.pc)

# debug
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/pinocchio.pc ${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/pinocchio3.pc)

# 复制头文件并替换 #include "pinocchio/ 为 #include "pinocchio3/
file(GLOB_RECURSE HEADER_FILES "${CURRENT_PACKAGES_DIR}/include/pinocchio/*")
foreach(HEADER_FILE ${HEADER_FILES})
    # 获取相对路径
    file(RELATIVE_PATH RELATIVE_PATH "${CURRENT_PACKAGES_DIR}/include/pinocchio" "${HEADER_FILE}")
    
    # 创建目标目录
    get_filename_component(TARGET_DIR "${CURRENT_PACKAGES_DIR}/include/pinocchio3/${RELATIVE_PATH}" DIRECTORY)
    file(MAKE_DIRECTORY "${TARGET_DIR}")
    
    # 如果是文本文件（.hpp, .h, .hxx等），替换内容
    if(HEADER_FILE MATCHES "\\.(hpp|h|hxx|tpp|ipp|inl|xpp|txx)$")
        # 读取文件内容
        file(READ "${HEADER_FILE}" FILE_CONTENT)
        
        # 替换 #include "pinocchio/ 为 #include "pinocchio3/
        string(REPLACE "#include \"pinocchio/" "#include \"pinocchio3/" FILE_CONTENT "${FILE_CONTENT}")
        string(REPLACE "#include <pinocchio/" "#include <pinocchio3/" FILE_CONTENT "${FILE_CONTENT}")
        string(REPLACE " \"pinocchio/" " \"pinocchio3/" FILE_CONTENT "${FILE_CONTENT}")

        # 写回文件
        file(WRITE "${CURRENT_PACKAGES_DIR}/include/pinocchio3/${RELATIVE_PATH}" "${FILE_CONTENT}")
    else()
        # 非头文件直接复制
        file(COPY "${HEADER_FILE}" DESTINATION "${TARGET_DIR}")
    endif()
endforeach()

# 删除原始的pinocchio头文件目录
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/pinocchio")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" COPYONLY)
