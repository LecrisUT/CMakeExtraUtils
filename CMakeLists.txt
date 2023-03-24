cmake_minimum_required(VERSION 3.16)

# TODO: Remove when cmake 3.25 is commonly distributed
if (POLICY CMP0140)
	cmake_policy(SET CMP0140 NEW)
endif ()

list(PREPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR}/cmake)

include(DynamicVersion)
dynamic_version(PROJECT_PREFIX CMakeExtraUtils_)

project(CMakeExtraUtils
		VERSION ${PROJECT_VERSION}
		LANGUAGES NONE)

# Install this package for find_package or propagate variables for FetchContent
if (CMAKE_PROJECT_NAME STREQUAL PROJECT_NAME)
	# Install for find_package
	# At least one language has to be defined for GNUInstallDirs
	enable_language(CXX)
	include(CMakePackageConfigHelpers)
	include(GNUInstallDirs)
	# Package files
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
	# Bundled cmake files
	install(FILES
			cmake/DynamicVersion.cmake
			cmake/PackageComps.cmake
			DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/CMakeExtraUtils
			)
else ()
	# Propagate variables for FetchContent
	# All variables have to be consistent with CMakeExtraUtilsConfig.cmake
	if (CMAKE_VERSION VERSION_LESS 3.25)
		# TODO: Remove when cmake 3.25 is commonly distributed
		set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} PARENT_SCOPE)
		set(CMakeExtraUtils_VERSION ${CMakeExtraUtils_VERSION} PARENT_SCOPE)
		set(CMakeExtraUtils_VERSION_MAJOR ${CMakeExtraUtils_VERSION_MAJOR} PARENT_SCOPE)
		set(CMakeExtraUtils_VERSION_MINOR ${CMakeExtraUtils_VERSION_MINOR} PARENT_SCOPE)
		set(CMakeExtraUtils_VERSION_PATCH ${CMakeExtraUtils_VERSION_PATCH} PARENT_SCOPE)
		set(CMakeExtraUtils_VERSION_TWEAK ${CMakeExtraUtils_VERSION_TWEAK} PARENT_SCOPE)
	endif ()
	return(PROPAGATE
			CMAKE_MODULE_PATH
			CMakeExtraUtils_VERSION
			CMakeExtraUtils_VERSION_MAJOR
			CMakeExtraUtils_VERSION_MINOR
			CMakeExtraUtils_VERSION_PATCH
			CMakeExtraUtils_VERSION_TWEAK
			)
endif ()
