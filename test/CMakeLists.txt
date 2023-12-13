cmake_minimum_required(VERSION 3.20)
list(APPEND CMAKE_MESSAGE_CONTEXT Test)
project(CMakeExtraUtils_test
		LANGUAGES NONE
)
enable_testing()

# Not importing CMakeExtraUtils itself here since these will always be done by internal cmake projects

function(CMakeExtraUtils_add_test test)
	#[===[.md
	# CMakeExtraUtils_add_test

	Internal helper for adding functional tests specific for the current template project

	## Synopsis
	```cmake
	CMakeExtraUtils_add_test(<name>
			[TEST_NAME <test_name>]
			[TARGET <target>]
			[LABELS <label1> <label2>])
	```

	## Options

	`<name>`
	  Path to the CMake project to be executed relative to `${CMAKE_CURRENT_SOURCE_DIR}`

	`TEST_NAME` [Default: `<name>`]
	  Name for the test to be used as the ctest name

	`LABELS`
	  Additional labels to be added

	]===]

	list(APPEND CMAKE_MESSAGE_CONTEXT "CMakeExtraUtils_add_test")

	set(ARGS_Options)
	set(ARGS_OneValue
			TEST_NAME
	)
	set(ARGS_MultiValue
			LABELS
	)
	cmake_parse_arguments(PARSE_ARGV 1 ARGS "${ARGS_Options}" "${ARGS_OneValue}" "${ARGS_MultiValue}")
	# Check required/optional arguments
	if (ARGC LESS 1)
		message(FATAL_ERROR "Missing test name")
	endif ()
	if (NOT DEFINED ARGS_TEST_NAME)
		set(ARGS_TEST_NAME ${test})
	endif ()
	set(extra_args)
	if (CMakeExtraUtils_IS_TOP_LEVEL)
		# If it's run by main project use the export paths
		list(APPEND extra_args
				-DFETCHCONTENT_TRY_FIND_PACKAGE_MODE=ALWAYS
				# Generated Config file point to binary targets until it is installed
				-DCMakeExtraUtils_ROOT=${CMakeExtraUtils_BINARY_DIR}
				-DFETCHCONTENT_SOURCE_DIR_CMAKEEXTRAUTILS=${CMakeExtraUtils_SOURCE_DIR}
		)
	elseif (DEFINED CMakeExtraUtils_ROOT)
		# Alternatively, if it's run by the tmt runner, CMakeExtraUtils is either pre-installed or we have pre-built it
		# and exported to `CMakeExtraUtils_ROOT`
		list(APPEND extra_args
				-DCMakeExtraUtils_ROOT=${CMakeExtraUtils_ROOT}
		)
	endif ()

	add_test(NAME ${ARGS_TEST_NAME}
			COMMAND ${CMAKE_CTEST_COMMAND} --build-and-test ${CMAKE_CURRENT_SOURCE_DIR}/${test}
			${CMAKE_CURRENT_BINARY_DIR}/${test}
			# Use the same build environment as the current runner
			--build-generator "${CMAKE_GENERATOR}"
			--build-options
			${extra_args}
			--test-command ${CMAKE_CTEST_COMMAND}
			--test-dir ${CMAKE_CURRENT_BINARY_DIR}/${test}
			--output-on-failure
			# Generally ignore if no tests are bundled
			--no-tests=ignore
	)
	set_tests_properties(${ARGS_TEST_NAME} PROPERTIES
			LABELS "${ARGS_LABELS}"
	)
endfunction()

foreach (test_type IN ITEMS
		package
)
	add_subdirectory(${test_type})
endforeach ()
