#!/bin/bash
# vim: dict+=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
. /usr/share/beakerlib/beakerlib.sh || exit 1

rlJournalStart
	rlPhaseStartSetup
		rlRun "tmp=\$(mktemp -d)" 0 "Create tmp directory"
		rlRun "rsync -r ./ $tmp" 0 "Copy test files"
		rlRun "pushd $tmp"
		rlRun "build_dir=./build" 0 "Set build_dir"
    rlRun "configure_args=\"-B \${build_dir} -G Ninja --log-context\"" 0 "Set configure_args"
    rlRun "build_args=\"--build \${build_dir}\"" 0 "Set build_args"
    [[ -n "$CMakeExtraUtils_ROOT" ]] && rlRun "configure_args=\"\${configure_args} -DCMakeExtraUtils_ROOT=\${CMakeExtraUtils_ROOT}\"" 0 "Add CMakeExtraUtils_ROOT"
    rlRun "echo '.git_archival.txt  export-subst' > .gitattributes" 0 "Configure .gitattributes"
		rlRun "set -o pipefail"
	rlPhaseEnd

	rlPhaseStartTest "Not a git repo not an archive: Should fail"
		rlRun -s "cmake ${configure_args}" 1 "CMake configure"
		rlAssertGrep "Found Git" $rlRun_LOG
		rlAssertGrep "fatal: not a git repository" $rlRun_LOG
		rlAssertGrep "Project source is neither a git repository nor a git archive" $rlRun_LOG
	rlPhaseEnd

	rlPhaseStartTest "No tag created: Should fail"
		rlRun "git init"
		rlRun "git add CMakeLists.txt .git_archival.txt .gitattributes src" 0 "Git add basic files"
		rlRun "git commit -m 'Initial commit'" 0 "Git commit (initial)"
		rlRun -s "cmake ${configure_args}" 1 "CMake configure"
		rlAssertGrep "fatal: No names found, cannot describe anything." $rlRun_LOG
	rlPhaseEnd

	rlPhaseStartTest "Tagged: Configure"
	  rlRun "tag_version='0.0.0'" 0 "Set tag_version"
		rlRun "git tag v\${tag_version}" 0 "Tag release"
		# Save the git metadata
		rlRun "commit=\$(git rev-parse HEAD)" 0 "Get git commit"
		rlRun "describe=\$(git describe --tags --long)" 0 "Get git describe"
		rlRun "distance=\$(echo \${describe} | sed 's/.*-(/d)+-.*/\1/')" 0 "Extract git distance"
		rlRun -s "cmake ${configure_args}" 0 "CMake configure"
		rlAssertGrep "\[TestProject\] version: ${tag_version}" $rlRun_LOG
		rlAssertGrep "\[TestProject\] commit: ${commit}" $rlRun_LOG
		rlAssertGrep "\[TestProject\] describe: ${describe}" $rlRun_LOG
		rlAssertGrep "\[TestProject\] distance: ${distance}" $rlRun_LOG
	rlPhaseEnd

	rlPhaseStartTest "Tagged: Build"
		rlRun -s "cmake ${build_args}" 0 "CMake build"
		rlRun -s "${build_dir}/version" 0 "Run ./version"
		rlAssertGrep "version: ${tag_version}" $rlRun_LOG
		rlRun -s "${build_dir}/commit" 0 "Run ./commit"
		rlAssertGrep "version: ${tag_version}" $rlRun_LOG
		rlAssertGrep "commit: ${commit}" $rlRun_LOG
		rlAssertGrep "describe: ${describe}" $rlRun_LOG
		rlAssertGrep "distance: ${distance}" $rlRun_LOG
	rlPhaseEnd

	rlPhaseStartTest "Tagged: Build (Repeat)"
	  # Running build again should not trigger a re-configure
		rlRun -s "cmake ${build_args}" 0 "CMake build"
		rlAssertNotGrep "Re-running CMake" $rlRun_LOG
		rlRun -s "cmake ${build_args}" 0 "CMake build"
		rlAssertNotGrep "Re-running CMake" $rlRun_LOG
		rlRun -s "${build_dir}/version" 0 "Run ./version"
		rlAssertGrep "version: ${tag_version}" $rlRun_LOG
		rlRun -s "${build_dir}/commit" 0 "Run ./commit"
		rlAssertGrep "version: ${tag_version}" $rlRun_LOG
		rlAssertGrep "commit: ${commit}" $rlRun_LOG
		rlAssertGrep "describe: ${describe}" $rlRun_LOG
		rlAssertGrep "distance: ${distance}" $rlRun_LOG
	rlPhaseEnd

	rlPhaseStartTest "Off-tag: Build"
		rlRun "touch ./random_file" 0 "Create a random file"
		rlRun "git add random_file" 0 "Git add the random file"
		rlRun "git commit -m 'Moved commit'" 0 "Git commit (off-tag)"
		rlRun "commit=\$(git rev-parse HEAD)" 0 "Get git commit"
		rlRun "describe=\$(git describe --tags --long)" 0 "Get git describe"
		rlRun "distance=\$(echo \${describe} | sed 's/.*-(/d)+-.*/\1/')" 0 "Extract git distance"
		# Version did not change, it should not re-configure
		rlRun -s "cmake ${build_args} -t version" 0 "CMake build (version) 1st"
		rlAssertNotGrep "Re-running CMake" $rlRun_LOG
		rlRun -s "cmake ${build_args} -t version" 0 "CMake build (version) 2nd"
		rlAssertNotGrep "Re-running CMake" $rlRun_LOG
		rlRun -s "${build_dir}/version" 0 "Run ./version"
		rlAssertGrep "version: ${tag_version}" $rlRun_LOG
		# Commit changed, it should re-configure
		rlRun -s "cmake ${build_args} -t commit" 0 "CMake build (commit) 1st"
		rlAssertNotGrep "Re-running CMake" $rlRun_LOG
		rlRun -s "cmake ${build_args} -t commit" 0 "CMake build (commit) 2nd"
		rlAssertGrep "Re-running CMake" $rlRun_LOG
		rlAssertGrep "version: ${tag_version}" $rlRun_LOG
		rlAssertGrep "commit: ${commit}" $rlRun_LOG
		rlAssertGrep "describe: ${describe}" $rlRun_LOG
		rlAssertGrep "distance: ${distance}" $rlRun_LOG
		rlRun -s "${build_dir}/commit" 0 "Run ./commit"
		rlAssertGrep "version: ${tag_version}" $rlRun_LOG
		rlAssertGrep "commit: ${commit}" $rlRun_LOG
		rlAssertGrep "describe: ${describe}" $rlRun_LOG
		rlAssertGrep "distance: ${distance}" $rlRun_LOG
	rlPhaseEnd

	rlPhaseStartTest "New tag: Build"
	  rlRun "tag_version='0.1.0'" 0 "Set tag_version"
		rlRun "git tag v\${tag_version}" 0 "Tag commit"
		rlRun "describe=\$(git describe --tags --long)" 0 "Get git describe"
		rlRun "distance=\$(echo \${describe} | sed 's/.*-(/d)+-.*/\1/')" 0 "Extract git distance"
		# Commit did not change, it should not re-configure
		rlRun -s "cmake ${build_args} -t commit" 0 "CMake build (commit) 1st"
		rlAssertNotGrep "Re-running CMake" $rlRun_LOG
		rlRun -s "cmake ${build_args} -t commit" 0 "CMake build (commit) 2nd"
		rlAssertNotGrep "Re-running CMake" $rlRun_LOG
		rlRun -s "${build_dir}/commit" 0 "Run ./commit"
		rlAssertGrep "commit: ${commit}" $rlRun_LOG
		# Version changed, it should re-configure
		rlRun -s "cmake ${build_args} -t version" 0 "CMake build (version) 1st"
		rlAssertNotGrep "Re-running CMake" $rlRun_LOG
		rlRun -s "cmake ${build_args} -t version" 0 "CMake build (version) 2nd"
		rlAssertGrep "Re-running CMake" $rlRun_LOG
		rlAssertGrep "version: ${tag_version}" $rlRun_LOG
		rlAssertGrep "commit: ${commit}" $rlRun_LOG
		rlAssertGrep "describe: ${describe}" $rlRun_LOG
		rlAssertGrep "distance: ${distance}" $rlRun_LOG
		rlRun -s "${build_dir}/version" 0 "Run ./version"
		rlAssertGrep "version: ${tag_version}" $rlRun_LOG
		# Check the version and describe again for completeness
		rlRun -s "cmake ${build_args} -t commit" 0 "CMake build (commit) 3rd"
		rlAssertNotGrep "Re-running CMake" $rlRun_LOG
		rlRun -s "${build_dir}/commit" 0 "Run ./commit"
		rlAssertGrep "version: ${tag_version}" $rlRun_LOG
		rlAssertGrep "commit: ${commit}" $rlRun_LOG
		rlAssertGrep "describe: ${describe}" $rlRun_LOG
		rlAssertGrep "distance: ${distance}" $rlRun_LOG
	rlPhaseEnd


	rlPhaseStartCleanup
		rlRun "popd"
		rlRun "rm -r $tmp" 0 "Remove tmp directory"
	rlPhaseEnd
rlJournalEnd
