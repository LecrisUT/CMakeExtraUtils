#!/bin/bash
# vim: dict+=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
. /usr/share/beakerlib/beakerlib.sh || exit 1

rlJournalStart
	rlPhaseStartSetup
		rlRun "tmp=\$(mktemp -d)" 0 "Create tmp directory"
		rlRun "rsync -r ./ $tmp" 0 "Copy test files"
		rlRun "pushd $tmp"
		rlRun "build_dir=./build" 0 "Set build_dir"
    rlRun "configure_args=\"-B \${build_dir} -G Ninja --log-context --fresh\"" 0 "Set configure_args"
    rlRun "build_args=\"--build \${build_dir} -v\"" 0 "Set build_args"
    [[ -n "$CMakeExtraUtils_ROOT" ]] && rlRun "configure_args=\"\${configure_args} -DCMakeExtraUtils_ROOT=\${CMakeExtraUtils_ROOT}\"" 0 "Add CMakeExtraUtils_ROOT"
    rlRun "echo '.git_archival.txt  export-subst' > .gitattributes" 0 "Configure .gitattributes"
		rlRun "set -o pipefail"
		rlRun "git init"
		rlRun "git add CMakeLists.txt .git_archival.txt .gitattributes src" 0 "Git add basic files"
		rlRun "git commit -m 'Initial commit'" 0 "Git commit (initial)"
	rlPhaseEnd

	rlPhaseStartTest "No tag created: Should fail"
	  rlRun "archive_name='no_tag'" 0 "Set archive_name"
	  rlRun "git archive HEAD --prefix=${archive_name}/ -o ${archive_name}.tar.gz" 0 "Git archive"
	  rlRun "tar -xf ${archive_name}.tar.gz" 0 "Extract archive"
		rlRun -s "cmake -S ${archive_name} ${configure_args}" 1 "CMake configure"
		# TODO: Missing appropriate rlAssertGrep
	rlPhaseEnd

	rlPhaseStartTest "Tagged archive"
	  rlRun "archive_name='tagged'" 0 "Set archive_name"
	  rlRun "tag_version=0.0.0" 0 "Set tag_version"
		rlRun "git tag v\${tag_version}" 0 "Tag git commit"
		rlRun "commit=\$(git rev-parse HEAD)" 0 "Get git commit"
		rlRun "describe=\$(git describe --tags)" 0 "Get git describe"
	  rlRun "git archive HEAD --prefix=${archive_name}/ -o ${archive_name}.tar.gz" 0 "Git archive"
	  rlRun "tar -xf ${archive_name}.tar.gz" 0 "Extract archive"
		rlRun -s "cmake -S ${archive_name} ${configure_args}" 0 "CMake configure"
		rlAssertGrep "\[TestProject\] version: ${tag_version}" $rlRun_LOG
		rlAssertGrep "\[TestProject\] commit: ${commit}" $rlRun_LOG
		rlAssertGrep "\[TestProject\] describe: ${describe}" $rlRun_LOG
		rlRun -s "cmake ${build_args}" 0 "CMake build"
		rlRun -s "${build_dir}/version" 0 "Run ./version"
		rlAssertGrep "version: ${tag_version}" $rlRun_LOG
		rlRun -s "${build_dir}/commit" 0 "Run ./commit"
		rlAssertGrep "version: ${tag_version}" $rlRun_LOG
		rlAssertGrep "commit: ${commit}" $rlRun_LOG
		rlAssertGrep "describe: ${describe}" $rlRun_LOG
	rlPhaseEnd

	rlPhaseStartTest "Off-tag archive"
	  rlRun "archive_name='off-tag'" 0 "Set archive_name"
		rlRun "touch ./random_file" 0 "Create a random file"
		rlRun "git add random_file" 0 "Git add the random file"
		rlRun "git commit -m 'Moved commit'" 0 "Git commit (off-tag)"
		rlRun "commit=\$(git rev-parse HEAD)" 0 "Get git commit"
		rlRun "describe=\$(git describe --tags)" 0 "Get git describe"
	  rlRun "git archive HEAD --prefix=${archive_name}/ -o ${archive_name}.tar.gz" 0 "Git archive"
	  rlRun "tar -xf ${archive_name}.tar.gz" 0 "Extract archive"
		rlRun -s "cmake -S ${archive_name} ${configure_args}" 0 "CMake configure"
		rlAssertGrep "\[TestProject\] version: ${tag_version}" $rlRun_LOG
		rlAssertGrep "\[TestProject\] commit: ${commit}" $rlRun_LOG
		rlAssertGrep "\[TestProject\] describe: ${describe}" $rlRun_LOG
		rlRun -s "cmake ${build_args}" 0 "CMake build"
		rlRun -s "${build_dir}/version" 0 "Run ./version"
		rlAssertGrep "version: ${tag_version}" $rlRun_LOG
		rlRun -s "${build_dir}/commit" 0 "Run ./commit"
		rlAssertGrep "version: ${tag_version}" $rlRun_LOG
		rlAssertGrep "commit: ${commit}" $rlRun_LOG
		rlAssertGrep "describe: ${describe}" $rlRun_LOG
	rlPhaseEnd

	rlPhaseStartCleanup
		rlRun "popd"
		rlRun "rm -r $tmp" 0 "Remove tmp directory"
	rlPhaseEnd
rlJournalEnd
