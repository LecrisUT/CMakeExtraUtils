#!/bin/bash
# vim: dict+=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
. /usr/share/beakerlib/beakerlib.sh || exit 1

rlJournalStart
	rlPhaseStartSetup
		rlRun "tmp=\$(mktemp -d)" 0 "Create tmp directory"
		rlRun "rsync -r ./ $tmp" 0 "Copy test files"
		rlRun "pushd $tmp"
		rlRun "set -o pipefail"
	rlPhaseEnd

	rlPhaseStartTest "test: find_package"
		rlRun "cmake -B ./build_find_package . -DFETCHCONTENT_TRY_FIND_PACKAGE_MODE=ALWAYS"
		rlAssertNotExists ./build_find_package/_deps
	rlPhaseEnd

	rlPhaseStartTest "test: FetchContent"
		rlRun "cmake -B ./build_FetchContent . -DFETCHCONTENT_TRY_FIND_PACKAGE_MODE=NEVER"
		rlAssertExists ./build_FetchContent/_deps
	rlPhaseEnd

	rlPhaseStartCleanup
		rlRun "popd"
		rlRun "rm -r $tmp" 0 "Remove tmp directory"
	rlPhaseEnd
rlJournalEnd
