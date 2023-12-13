#!/bin/bash
# vim: dict+=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# shellcheck disable=all
source /usr/share/beakerlib/beakerlib.sh || exit 1

rlJournalStart
  rlPhaseStartSetup
    rlRun "tmp=\$(mktemp -d)" 0 "Create tmp directory"
    rlRun "rsync -rL ./ $tmp" 0 "Copy example project"
    rlRun "pushd $tmp"
    extra_args=""
    [[ -n "$CMakeExtraUtils_ROOT" ]] && extra_args="$extra_args -DCMakeExtraUtils_ROOT=$CMakeExtraUtils_ROOT"
    rlRun "set -o pipefail"
  rlPhaseEnd

  rlPhaseStartTest
    rlRun "cmake -B ./build ${extra_args}"
    rlRun "cmake --build ./build"
    rlRun "ctest --test-dir ./build --output-on-failure"
  rlPhaseEnd

  rlPhaseStartCleanup
    rlRun "popd"
    rlRun "rm -r $tmp" 0 "Remove tmp directory"
  rlPhaseEnd
rlJournalEnd
