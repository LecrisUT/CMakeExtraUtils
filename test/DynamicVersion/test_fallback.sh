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
	node: \$Format:%H\$
	node-date: \$Format:%cI\$
	describe-name: \$Format:%(describe:tags=true,match=?[0-9.]*)\$
	ref-names: \$Format:%D\$
EOF
	rlPhaseEnd

	rlPhaseStartTest "Not a git repo and not an archive"
		rlRun "cmake -B ./build . $extra_args" 1 "Fail without fallback"
		rlRun "cmake -B ./build . -DFALLBACK_VERSION=0.1.2 $extra_args" 0 "Succeed when using fallback"
	rlPhaseEnd

	rlPhaseStartCleanup
		rlRun "popd"
		rlRun "rm -r $tmp" 0 "Remove tmp directory"
	rlPhaseEnd
rlJournalEnd
