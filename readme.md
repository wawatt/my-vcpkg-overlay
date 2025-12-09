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
移动my-vcpkg-overlay/vcpkg.json到vcpkg根目录
```shell
./vcpkg install
./vcpkg.exe export --zip --output-dir=d:/vcpkg-export --x-all-installed
```
3. 单独安装
```
./vcpkg install ruckig --overlay-ports=E:\ENVs\vcpkgs\my-vcpkg-overlay
```

## 参考
* https://learn.microsoft.com/zh-cn/vcpkg/get_started/get-started-packaging?pivots=shell-cmd