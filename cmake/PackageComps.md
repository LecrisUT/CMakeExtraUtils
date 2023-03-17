# [`PackageComps.cmake`](PackageComps.cmake)

Export and import targets as individual components. Special components `shared` and `static`

## Example

The main `CMakeLists.txt` that exports the target:
```cmake
cmake_minimum_required(VERSION 3.25)

project(My_Project)

find_package(CmakeExtraUtils REQUIRED)
include(PackageComps)

add_library(my_component_library)
# Export as a component
export_component(COMPONENT my_component)

# Usual export configuration
include(CMakePackageConfigHelpers)
write_basic_package_version_file(
		My_ProjectConfigVersion.cmake
		VERSION ${PROJECT_VERSION}
		COMPATIBILITY SameMajorVersion)
configure_package_config_file(
		cmake/My_ProjectConfig.cmake.in
		My_ProjectConfig.cmake
		INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/My_Project)
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/My_ProjectConfigVersion.cmake
		${CMAKE_CURRENT_BINARY_DIR}/My_ProjectConfig.cmake
		## Consider bundling PackageComps.cmake to minimize dependency
        # /path/to/PackageComps.cmake
		DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/My_Project)
```
with `My_ProjectConfig.cmake.in`
```cmake
find_package(CmakeExtraUtils REQUIRED)
include(PackageComps)
## Or if bundled
# include(${CURRENT_LIST_DIR}/PackageComps.cmake)
find_components(COMPONENTS my_component)
```

The user will then be able to use:
```cmake
cmake_minimum_required(VERSION 3.25)

project(Downstream_Project)

find_package(My_Project COMPONENTS my_component)
```