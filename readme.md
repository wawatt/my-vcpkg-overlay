# 常用的vcpkg以外的库

## 使用
1. clone vcpkg
```shell
git clone https://github.com/microsoft/vcpkg.git -b 2025.09.17
cd vcpkg
.\bootstrap-vcpkg.bat
git clone https://github.com/wawatt/my-vcpkg-overlay.git
```
2. 全局安装
把 `my-vcpkg-overlay/vcpkg.jsonx` 覆盖到 vcpkg 根目录的 `vcpkg.json`（已含 overlay-ports / overlay-triplets 和 `tesseract-robotics`）：
```shell
./vcpkg install
./vcpkg.exe export --zip --output-dir=d:/vcpkg-export --x-all-installed
```
3. 单独安装
```
./vcpkg install ruckig --overlay-ports=E:\ENVs\vcpkgs\my-vcpkg-overlay
```

## ompl（仅 Windows）

Overlay 端口名 **`ompl`**，覆盖官方 `ompl` 1.7.0。内容是 **OMPL 2.0.2**（`ompl/ompl` main `48552087`）加上桌面仓库 `win` 分支的 MSVC + VAMP 补丁。`supports: windows`。MSVC 下为静态库，带 VAMP（AVX2）。

```
./vcpkg install ompl --overlay-ports=my-vcpkg-overlay --overlay-triplets=my-vcpkg-overlay/triplets
```

```cmake
find_package(ompl CONFIG REQUIRED)
target_link_libraries(main PRIVATE ompl::ompl)
```

## tesseract-robotics

运动规划框架（[tesseract-robotics/tesseract](https://github.com/tesseract-robotics/tesseract)），**不是** OCR 的 `tesseract`。仅 Windows，无 ROS/ROS2。

```
./vcpkg install tesseract-robotics --overlay-ports=my-vcpkg-overlay --overlay-triplets=my-vcpkg-overlay/triplets
```

CMake 入口是端口名（不要用 `find_package(tesseract)`，那会撞上 OCR）。导入目标仍是 `tesseract::*`：

```cmake
find_package(tesseract-robotics CONFIG REQUIRED)
target_link_libraries(main PRIVATE tesseract::environment)
```

## 参考
* https://learn.microsoft.com/zh-cn/vcpkg/get_started/get-started-packaging?pivots=shell-cmd