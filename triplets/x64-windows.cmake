set(VCPKG_TARGET_ARCHITECTURE x64)
set(VCPKG_CRT_LINKAGE dynamic)
set(VCPKG_LIBRARY_LINKAGE static)
set(VCPKG_BUILD_TYPE release)
set(MY_SHARED_LIST
    "assimp" 
    "casadi"
    "hpp-fcl"
    "fcl"
    "onnxruntime-gpu"
    "opencv4"
    "ompl"
    "openvino"
    "nodeeditor"
    "python3"
    "toppra"
    "zstd"
)
list(FIND MY_SHARED_LIST "${PORT}" INDEX)

# 如果INDEX大于或等于0，则字符串在列表中
if(${INDEX} GREATER -1)
    set(VCPKG_LIBRARY_LINKAGE dynamic)
endif()

if("${PORT}" MATCHES "pinocchio") # for pinocchio3 and pinocchio2
    set(VCPKG_LIBRARY_LINKAGE dynamic)
endif()

if("${PORT}" MATCHES "boost")
    set(VCPKG_LIBRARY_LINKAGE dynamic)
endif()

if("${PORT}" MATCHES "qt")
    set(VCPKG_LIBRARY_LINKAGE dynamic)
endif()

message("")
message("---------${PORT}--------LIBRARY: ${VCPKG_LIBRARY_LINKAGE}  CRT: ${VCPKG_CRT_LINKAGE}----")
