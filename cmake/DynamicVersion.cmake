## Helper to get dynamic version
# Format is made compatible with python's setuptools_scm (https://github.com/pypa/setuptools_scm#git-archives)

function(get_dynamic_version)
	# Named arguments::
	#   OUTPUT_NAME (string) [PROJECT_VERSION]: Variable where to save the calculated version
	#   OUTPUT_DESCRIBE (string) [GIT_DESCRIBE]: Variable where to save the pure git_describe
	#   PROJECT_SOURCE (path) [${CMAKE_CURRENT_SOURCE_DIR}]: Location of the project source.
	#     (either extracted git archive or git clone)
	#   GIT_ARCHIVAL_FILE (path) [${PROJECT_SOURCE}/.git_archival.txt]: Location of .git_archival.txt
	#   FALLBACK_VERSION (string): Fallback version
	#
	# Options::
	#   ALLOW_FAILS: Do not return with FATAL_ERROR. Developer is responsible for setting appropriate version if fails
	#
	# Note: this approach does not reconfigure the build.
	# For CPM.cmake it is irrelevant because it does not have any builds

	cmake_parse_arguments(ARGS
			"ALLOW_FAILS"
			"OUTPUT_NAME;OUTPUT_DESCRIBE;PROJECT_SOURCE;GIT_ARCHIVAL_FILE;FALLBACK_VERSION"
			""
			${ARGN})

	# Set default values
	if (NOT DEFINED ARGS_OUTPUT_NAME)
		set(ARGS_OUTPUT_NAME "PROJECT_VERSION")
	endif ()
	if (NOT DEFINED ARGS_OUTPUT_DESCRIBE)
		set(ARGS_OUTPUT_DESCRIBE "GIT_DESCRIBE")
	endif ()
	if (NOT DEFINED ARGS_PROJECT_SOURCE)
		set(ARGS_PROJECT_SOURCE ${CMAKE_CURRENT_SOURCE_DIR})
	endif ()
	if (NOT DEFINED ARGS_GIT_ARCHIVAL_FILE)
		set(ARGS_GIT_ARCHIVAL_FILE ${ARGS_PROJECT_SOURCE}/.git_archival.txt)
	endif ()
	if (DEFINED ARGS_FALLBACK_VERSION OR ARGS_ALLOW_FAILS)
		# If we have a fallback version or it is specified it is ok if this fails, don't make messages FATAL_ERROR
		set(error_message_type AUTHOR_WARNING)
	else ()
		# Otherwise it should
		set(error_message_type FATAL_ERROR)
	endif ()


	if (DEFINED ARGS_FALLBACK_VERSION)
		set(${ARGS_OUTPUT_NAME} ${ARGS_FALLBACK_VERSION})
	endif ()

	# Get version dynamically from git_archival.txt
	file(STRINGS ${ARGS_GIT_ARCHIVAL_FILE} describe-name
			REGEX "^describe-name:.*")
	if (NOT describe-name)
		# If git_archival.txt does not contain the field "describe-name:", it is ill-formed
		message(${error_message_type}
				"DynamicVersion: Missing file or string \"describe-name\" in .git_archival.txt\n"
				"  .git_archival.txt: ${ARGS_GIT_ARCHIVAL_FILE}")
		return()
	endif ()

	# Try to get the version tag of the form `vX.Y.Z` or `X.Y.Z` (with arbitrary suffix)
	if (describe-name MATCHES "^describe-name:[ ]?([v]?([0-9\\.]+).*)")
		# First matched group is the full `git describe` of the latest tag
		# Second matched group is only the version, i.e. `X.Y.Z`
		set(${ARGS_OUTPUT_DESCRIBE} ${CMAKE_MATCH_1} PARENT_SCOPE)
		set(${ARGS_OUTPUT_NAME} ${CMAKE_MATCH_2} PARENT_SCOPE)
		message(DEBUG
				"DynamicVersion: Found appropriate tag in .git_archival.txt file:\n"
				"  Describe-name: ${${ARGS_OUTPUT_DESCRIBE}}\n"
				"  Version: ${${ARGS_OUTPUT_NAME}}")
	else ()
		# If not it has to be computed from the git archive
		find_package(Git REQUIRED)
		# Test if
		execute_process(COMMAND ${GIT_EXECUTABLE} status
				WORKING_DIRECTORY ${ARGS_PROJECT_SOURCE}
				RESULT_VARIABLE git_status_result)
		if (NOT git_status_result EQUAL 0)
			message(${error_message_type}
					"DynamicVersion: Project source is neither a git repository nor a git archive:\n"
					"  Source: ${ARGS_PROJECT_SOURCE}")
			return()
		endif ()
		execute_process(COMMAND ${GIT_EXECUTABLE} describe --tags --match=?[0-9.]*
				WORKING_DIRECTORY ${ARGS_PROJECT_SOURCE}
				OUTPUT_VARIABLE describe-name
				COMMAND_ERROR_IS_FATAL ANY)
		# Match any part containing digits and periods (strips out rc and so on)
		if (NOT describe-name MATCHES "^([v]?([0-9\\.]+).*)")
			message(${error_message_type}
					"DynamicVersion: Version tag is ill-formatted\n"
					"  Describe-name: ${describe-name}")
			return()
		endif ()
		set(${ARGS_OUTPUT_DESCRIBE} ${CMAKE_MATCH_1} PARENT_SCOPE)
		set(${ARGS_OUTPUT_NAME} ${CMAKE_MATCH_2} PARENT_SCOPE)
		message(DEBUG
				"DynamicVersion: Found appropriate tag from git:\n"
				"  Describe-name: ${${ARGS_OUTPUT_DESCRIBE}}\n"
				"  Version: ${${ARGS_OUTPUT_NAME}}")
	endif ()
	message(VERBOSE
			"DynamicVersion: Calculated version = ${${ARGS_OUTPUT_NAME}}")
endfunction()
