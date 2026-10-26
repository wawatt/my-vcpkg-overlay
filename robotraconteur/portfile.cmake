vcpkg_check_features(OUT_FEATURE_FLAGS FEATURE_FLAGS
    FEATURES
        hardware-transport ROBOTRACONTEUR_ENABLE_HARDWARE_TRANSPORT
)

if(VCPKG_TARGET_IS_LINUX AND ROBOTRACONTEUR_ENABLE_HARDWARE_TRANSPORT)
    MESSAGE(WARNING "${PORT} requires libbluetooth-dev from the system package manager.\nTry: 'sudo yum install libbluetooth-dev ' (or sudo apt-get install libbluetooth-dev)")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO robotraconteur/robotraconteur
    REF "v${VERSION}"
    SHA512 ce66b853e8beab53f10b9df310446ac97d4ba61c616f9ced560eb1d26c3d1c44bbeadf33ab109fd64295d5f6521a39eddbd14c03d847a99cdcb2d0d0511d6a87
    HEAD_REF master
)

# 当未启用 hardware-transport 特性时，就地旁路 Linux 硬件依赖（无需任何额外 patch 补丁文件）
if(NOT ROBOTRACONTEUR_ENABLE_HARDWARE_TRANSPORT)
    vcpkg_replace_string("${SOURCE_PATH}/RobotRaconteurCore/src/HardwareTransport.cpp"
        "defined(ROBOTRACONTEUR_LINUX) && !defined(ROBOTRACONTEUR_ANDROID)" "0")
    vcpkg_replace_string("${SOURCE_PATH}/RobotRaconteurCore/CMakeLists.txt"
        "find_path(LIBUSB_INCLUDE_DIR libusb.h PATH_SUFFIXES libusb-1.0)" "")
    vcpkg_replace_string("${SOURCE_PATH}/RobotRaconteurCore/CMakeLists.txt"
        "find_path(DBUS_INCLUDE_DIR dbus.h NAMES dbus/dbus.h PATH_SUFFIXES dbus-1.0)" "")
    vcpkg_replace_string("${SOURCE_PATH}/RobotRaconteurCore/CMakeLists.txt"
        "src/HardwareTransport_linux.cpp" "")
    vcpkg_replace_string("${SOURCE_PATH}/RobotRaconteurCore/CMakeLists.txt"
        "src/HardwareTransport_libusb.cpp" "")
    vcpkg_replace_string("${SOURCE_PATH}/RobotRaconteurCore/CMakeLists.txt"
        "src/HardwareTransport_usbcommon.cpp" "")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DBUILD_GEN=ON
        -DBUILD_TESTING=OFF
        -DCMAKE_CXX_STANDARD=11
)

vcpkg_cmake_install()

vcpkg_copy_tools(TOOL_NAMES RobotRaconteurGen AUTO_CLEAN)

vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/robotraconteur)

vcpkg_cmake_config_fixup(
    PACKAGE_NAME RobotRaconteur
    CONFIG_PATH "lib/cmake/RobotRaconteur"
)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
