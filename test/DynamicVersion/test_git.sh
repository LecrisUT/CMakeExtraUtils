#!/bin/bash
# vim: dict+=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
. /usr/share/beakerlib/beakerlib.sh || exit 1

rlJournalStart
	rlPhaseStartSetup
		rlRun "tmp=\$(mktemp -d)" 0 "Create tmp directory"
		rlRun "rsync -r ./ $tmp" 0 "Copy test files"
		rlRun "pushd $tmp"
		rlRun "set -o pipefail"
cat <<-EOF > .git_archival.txt
	node: \$Format:%H\$
	node-date: \$Format:%cI\$
	describe-name: \$Format:%(describe:tags=true,match=?[0-9.]*)\$
	ref-names: \$Format:%D\$
EOF
	rlPhaseEnd

	rlPhaseStartTest "Not a git repo not an archive: Should fail"
		rlRun "cmake -B ./build ." 1 "CMake should fail"
	rlPhaseEnd

	rlPhaseStartTest "No tag created: Should fail"
		rlRun "git init"
		rlRun "git add CMakeLists.txt"
		rlRun "git commit -m 'Initial commit'"
		rlRun "cmake -B ./build ." 1 "CMake should fail"
	rlPhaseEnd

	rlPhaseStartTest "Tagged"
		rlRun "git tag v0.0.0"
		rlRun "cmake -B ./build ."
	rlPhaseEnd

	rlPhaseStartCleanup
		rlRun "popd"
		rlRun "rm -r $tmp" 0 "Remove tmp directory"
	rlPhaseEnd
rlJournalEnd
