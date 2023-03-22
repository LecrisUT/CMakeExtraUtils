cmake_minimum_required(VERSION 3.16)

# TODO: Remove when cmake 3.25 is commonly distributed
if(POLICY CMP0140)
	cmake_policy(SET CMP0140 NEW)
endif()

list(PREPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR}/cmake)

include(DynamicVersion)
dynamic_version(PROJECT_PREFIX CMakeExtraUtils_)

project(CMakeExtraUtils
		VERSION ${PROJECT_VERSION})

include(CMakePackageConfigHelpers)
include(GNUInstallDirs)
write_basic_package_version_file(
		CMakeExtraUtilsConfigVersion.cmake
		VERSION ${PROJECT_VERSION}
		# TODO: Currently unstable api, change when v1.0 is released
		COMPATIBILITY SameMinorVersion
)
configure_package_config_file(
		cmake/CMakeExtraUtilsConfig.cmake.in
		CMakeExtraUtilsConfig.cmake
		INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/CMakeExtraUtils
)
install(FILES
		${CMAKE_CURRENT_BINARY_DIR}/CMakeExtraUtilsConfigVersion.cmake
		${CMAKE_CURRENT_BINARY_DIR}/CMakeExtraUtilsConfig.cmake
		DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/CMakeExtraUtils
		)
install(FILES
		cmake/DynamicVersion.cmake
		DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/CMakeExtraUtils
		)

