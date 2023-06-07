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

    rlPhaseStartTest "Basic test"
        rlRun "git init"
        rlRun "git add CMakeLists.txt"
        rlRun "git commit -m 'Initial commit'"
        rlRun "git tag v0.0.0"
        rlRun "cmake -B ./build ."
    rlPhaseEnd

    rlPhaseStartTest "No git"
        rlRun "cmake -B ./build ."
    rlPhaseEnd

    rlPhaseStartTest "No tag"
        rlRun "git init"
        rlRun "git add CMakeLists.txt"
        rlRun "git commit -m 'Initial commit'"
        rlRun "cmake -B ./build ."
    rlPhaseEnd

    rlPhaseStartCleanup
        rlRun "popd"
        rlRun "rm -r $tmp" 0 "Remove tmp directory"
    rlPhaseEnd
rlJournalEnd
