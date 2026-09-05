# Public entry: find_package(tesseract-robotics CONFIG REQUIRED)
# Upstream imported targets stay tesseract::*.
# Component configs call find_dependency(tesseract); pin tesseract_DIR so that
# resolves here instead of OCR TesseractConfig.cmake in share/tesseract.
set(tesseract_DIR "${CMAKE_CURRENT_LIST_DIR}" CACHE PATH "tesseract-robotics CMake package directory" FORCE)
include("${CMAKE_CURRENT_LIST_DIR}/tesseract-config.cmake")
