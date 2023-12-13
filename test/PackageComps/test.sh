#!/bin/bash
# vim: dict+=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
. /usr/share/beakerlib/beakerlib.sh || exit 1

rlJournalStart
	rlPhaseStartSetup
		rlRun "tmp=\$(mktemp -d)" 0 "Create tmp directory"
		rlRun "rsync -r ./ $tmp" 0 "Copy test files"
		rlRun "pushd $tmp"
    extra_args=""
    [[ -n "$CMakeExtraUtils_ROOT" ]] && extra_args="$extra_args -DCMakeExtraUtils_ROOT=$CMakeExtraUtils_ROOT"
		rlRun "set -o pipefail"
	rlPhaseEnd

	rlPhaseStartTest "test: simple provider/user"
		rlRun "cmake -B ./build_provider -S ./simple_provider -DCMAKE_INSTALL_PREFIX=install $extra_args"
		rlRun "cmake --build ./build_provider"
		rlRun "cmake --install ./build_provider"
		rlRun "cmake -B ./build_user -S ./simple_user -DTestProvider_ROOT=$(echo ./install/lib*/cmake/TestProvider) $extra_args"

	rlPhaseEnd

	rlPhaseStartCleanup
		rlRun "popd"
		rlRun "rm -r $tmp" 0 "Remove tmp directory"
	rlPhaseEnd
rlJournalEnd
