set_property(DIRECTORY APPEND
		PROPERTY LABELS package
)

foreach (test IN ITEMS
		FetchContent
		find_package
)
	CMakeExtraUtils_add_test(${test} TEST_NAME test-import-${test})
endforeach ()
