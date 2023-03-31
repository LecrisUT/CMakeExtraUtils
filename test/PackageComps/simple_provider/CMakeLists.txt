cmake_minimum_required(VERSION 3.25)

project(TestProvider VERSION 0.0.0)

find_package(CMakeExtraUtils REQUIRED)
include(PackageComps)

add_executable(hello src/hello.cpp)

export_component()
install(TARGETS hello
		EXPORT TestProviderTargets)

include(CMakePackageConfigHelpers)
write_basic_package_version_file(
		TestProviderConfigVersion.cmake
		VERSION ${PROJECT_VERSION}
		COMPATIBILITY AnyNewerVersion
)
configure_package_config_file(
		cmake/TestProviderConfig.cmake.in
		TestProviderConfig.cmake
		INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/TestProvider
)
install(FILES
		${CMAKE_CURRENT_BINARY_DIR}/TestProviderConfigVersion.cmake
		${CMAKE_CURRENT_BINARY_DIR}/TestProviderConfig.cmake
		DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/TestProvider
		)
