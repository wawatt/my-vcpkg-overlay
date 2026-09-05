# vcpkg port name is tesseract-planning; upstream CMake package name is tesseract_planning.
include(CMakeFindDependencyMacro)
find_dependency(tesseract-robotics)
find_dependency(tesseract_planning)
