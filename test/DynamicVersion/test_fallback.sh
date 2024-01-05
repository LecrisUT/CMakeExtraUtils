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
    rlRun "build_args=\"--build \${build_dir} -v\"" 0 "Set build_args"
    [[ -n "$CMakeExtraUtils_ROOT" ]] && rlRun "configure_args=\"\${configure_args} -DCMakeExtraUtils_ROOT=\${CMakeExtraUtils_ROOT}\"" 0 "Add CMakeExtraUtils_ROOT"
		rlRun "set -o pipefail"
	rlPhaseEnd

	rlPhaseStartTest "Not a git repo and not an archive: Should fail"
		rlRun -s "cmake ${configure_args}" 1 "CMake configure"
		rlAssertGrep "Project source is neither a git repository nor a git archive" $rlRun_LOG
	rlPhaseEnd

	rlPhaseStartTest "With fallback"
	  rlRun "fallback_version='0.1.2'" 0 "Set fallback_version"
		rlRun -s "cmake ${configure_args} -DFALLBACK_VERSION=${fallback_version}" 0 "CMake configure"
		rlAssertGrep "\[TestProject\] version: ${fallback_version}" $rlRun_LOG
		rlAssertGrep "\[TestProject\] commit: commit-NOTFOUND" $rlRun_LOG
		rlAssertGrep "\[TestProject\] describe: describe-NOTFOUND" $rlRun_LOG
		rlAssertGrep "\[TestProject\] distance: distance-NOTFOUND" $rlRun_LOG
		rlRun -s "cmake ${build_args}" 0 "CMake build"
		rlRun -s "${build_dir}/version" 0 "Run ./version"
		rlAssertGrep "version: ${fallback_version}" $rlRun_LOG
	rlPhaseEnd

	rlPhaseStartCleanup
		rlRun "popd"
		rlRun "rm -r $tmp" 0 "Remove tmp directory"
	rlPhaseEnd
rlJournalEnd
