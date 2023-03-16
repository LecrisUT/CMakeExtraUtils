cmake_minimum_required(VERSION 3.16)

# TODO: Remove when cmake 3.25 is commonly distributed
if(POLICY CMP0140)
	cmake_policy(SET CMP0140 NEW)
endif()

list(PREPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR}/cmake)

include(DynamicVersion)
dynamic_version(PROJECT_PREFIX CmakeExtraUtils_)

project(CmakeExtraUtils
		VERSION ${PROJECT_VERSION})

include(CMakePackageConfigHelpers)
include(GNUInstallDirs)
write_basic_package_version_file(
		CmakeExtraUtilsConfigVersion.cmake
		VERSION ${PROJECT_VERSION}
		# TODO: Currently unstable api, change when v1.0 is released
		COMPATIBILITY SameMinorVersion
)
configure_package_config_file(
		cmake/CmakeExtraUtilsConfig.cmake.in
		CmakeExtraUtilsConfig.cmake
		INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/CmakeExtraUtils
)
install(FILES
		${CMAKE_CURRENT_BINARY_DIR}/CmakeExtraUtilsConfigVersion.cmake
		${CMAKE_CURRENT_BINARY_DIR}/CmakeExtraUtilsConfig.cmake
		DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/CmakeExtraUtils
		)
install(FILES
		cmake/DynamicVersion.cmake
		DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/CmakeExtraUtils
		)

