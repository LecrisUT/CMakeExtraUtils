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
cat <<-EOF > .git_archival.txt
	node: d0157f38cf8e369c91ef3b144609b402ce9d18ff
	node-date: 2023-03-30T17:33:08+02:00
	describe-name: v0.1.2
	ref-names: v0.1.2
EOF
	rlPhaseEnd

	rlPhaseStartTest "Valid archive should work"
		rlRun "cmake -B ./build . $extra_args"
	rlPhaseEnd

	rlPhaseStartCleanup
		rlRun "popd"
		rlRun "rm -r $tmp" 0 "Remove tmp directory"
	rlPhaseEnd
rlJournalEnd
