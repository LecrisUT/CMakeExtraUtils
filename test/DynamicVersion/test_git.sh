#!/bin/bash
# vim: dict+=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
. /usr/share/beakerlib/beakerlib.sh || exit 1

rlJournalStart
	rlPhaseStartSetup
		rlRun "tmp=\$(mktemp -d)" 0 "Create tmp directory"
		rlRun "rsync -r ./ $tmp" 0 "Copy test files"
		rlRun "pushd $tmp"
    rlRun "build_dir=./build" 0 "Set temporary build_dir"
    rlRun "base_configure_args=\"-G Ninja --log-context\"" 0 "Set base_configure_args"
    [[ -n "$CMakeExtraUtils_ROOT" ]] && rlRun "base_configure_args=\"\${base_configure_args} -DCMakeExtraUtils_ROOT=\${CMakeExtraUtils_ROOT}\"" 0 "Add CMakeExtraUtils_ROOT"
    rlRun "configure_args=\"-B \${build_dir} \${base_configure_args}\" && echo \${configure_args}" 0 "Set temporary configure_args"
    rlRun "echo '.git_archival.txt  export-subst' > .gitattributes" 0 "Configure .gitattributes"
		rlRun "set -o pipefail"
		rlIsCentOS && rlRun "export PYTHONWARNINGS=\"ignore::RuntimeWarning\" && hatch_args=\"2>&1\" && hatch version || true" 0 "Workaround for hatch/setuptools_scm issue"
	rlPhaseEnd

  rlPhaseStartTest "Not a git repo not an archive: Should fail"
    rlRun -s "cmake ${configure_args}" 1 "CMake configure"
    rlAssertGrep "Found Git" $rlRun_LOG
    rlAssertGrep "fatal: not a git repository" $rlRun_LOG
    rlAssertGrep "Project source is neither a git repository nor a git archive" $rlRun_LOG
  rlPhaseEnd

	for mode in DEV POST; do
	  rlPhaseStartSetup "Reset arguments and git environment [${mode}]"
	    [[ -d .git ]] && rlRun "rm -rf .git" 0 "Clean git repository"
	    rlRun "sed -i -e 's/version_scheme=.*//g' pyproject.toml" 0 "Remove any version_scheme defined"
      case ${mode} in
      DEV)
        version_scheme=guess-next-dev
        ;;
      POST)
        version_scheme=post-release
        ;;
      *)
        rlFail "Unknown mode=${mode}"
        ;;
      esac
      rlRun "echo 'version_scheme=\"${version_scheme}\"' >> pyproject.toml && cat pyproject.toml" 0 "Setup version_scheme for ${mode}"
      rlRun "build_dir=./build-${mode}" 0 "Set specific build_dir"
      rlRun "configure_args=\"-B \${build_dir} \${base_configure_args} -DMODE=${mode}\" && echo \${configure_args}" 0 "Set full configure_args"
      rlRun "build_args=\"--build \${build_dir}\"" 0 "Set build_args"
	  rlPhaseEnd

    rlPhaseStartTest "No tag created: Should fail [${mode}]"
      rlRun "git init"
      rlRun "git add CMakeLists.txt .git_archival.txt .gitattributes src pyproject.toml" 0 "Git add basic files"
      rlRun "git commit -m 'Initial commit'" 0 "Git commit (initial)"
      rlRun -s "cmake ${configure_args}" 1 "CMake configure"
      rlAssertGrep "fatal: No names found, cannot describe anything." $rlRun_LOG
    rlPhaseEnd

    rlPhaseStartTest "Tagged: Configure [${mode}]"
      rlRun "tag_version='0.0.0'" 0 "Set tag_version"
      rlRun "git tag v\${tag_version}" 0 "Tag release"
      # Save the git metadata
      rlRun "commit=\$(git rev-parse HEAD) && echo \${commit}" 0 "Get git commit"
      rlRun "short_hash=\$(git rev-parse --short HEAD) && echo \${short_hash}" 0 "Get git short-hash"
      rlRun "describe=\$(git describe --tags --long) && echo \${describe}" 0 "Get git describe"
      rlRun "distance=\$(echo \${describe} | sed -E 's/.*-([0-9]+)-.*/\1/') && echo \${distance}" 0 "Extract git distance"
      rlRun "version_full=\$(hatch version ${hatch_args:-""}) && echo \${version_full}" 0 "Get setuptools_scm version"
      rlRun -s "cmake ${configure_args}" 0 "CMake configure"
      rlAssertGrep "^\[TestProject\] version: ${tag_version}\$" $rlRun_LOG
      rlAssertGrep "^\[TestProject\] version-full: ${version_full}\$" $rlRun_LOG
      rlAssertGrep "^\[TestProject\] commit: ${commit}\$" $rlRun_LOG
      rlAssertGrep "^\[TestProject\] short-hash: ${short_hash}\$" $rlRun_LOG
      rlAssertGrep "^\[TestProject\] describe: ${describe}\$" $rlRun_LOG
      rlAssertGrep "^\[TestProject\] distance: ${distance}\$" $rlRun_LOG
    rlPhaseEnd

    rlPhaseStartTest "Tagged: Build [${mode}]"
      rlRun -s "cmake ${build_args}" 0 "CMake build"
      rlRun -s "${build_dir}/version" 0 "Run ./version"
      rlAssertGrep "^version: ${tag_version}\$" $rlRun_LOG
      rlAssertGrep "version-full: ${version_full}" $rlRun_LOG -F
      rlRun -s "${build_dir}/commit" 0 "Run ./commit"
      rlAssertGrep "^version: ${tag_version}\$" $rlRun_LOG
      rlAssertGrep "version-full: ${version_full}" $rlRun_LOG -F
      rlAssertGrep "^commit: ${commit}\$" $rlRun_LOG
      rlAssertGrep "^short-hash: ${short_hash}\$" $rlRun_LOG
      rlAssertGrep "^describe: ${describe}\$" $rlRun_LOG
      rlAssertGrep "^distance: ${distance}\$" $rlRun_LOG
    rlPhaseEnd

    rlPhaseStartTest "Tagged: Build (Repeat) [${mode}]"
      # Running build again should not trigger a re-configure
      rlRun -s "cmake ${build_args}" 0 "CMake build"
      rlAssertNotGrep "Re-running CMake" $rlRun_LOG
      rlRun -s "cmake ${build_args}" 0 "CMake build"
      rlAssertNotGrep "Re-running CMake" $rlRun_LOG
      rlRun -s "${build_dir}/version" 0 "Run ./version"
      rlAssertGrep "^version: ${tag_version}\$" $rlRun_LOG
      rlAssertGrep "version-full: ${version_full}" $rlRun_LOG -F
      rlRun -s "${build_dir}/commit" 0 "Run ./commit"
      rlAssertGrep "^version: ${tag_version}\$" $rlRun_LOG
      rlAssertGrep "version-full: ${version_full}" $rlRun_LOG -F
      rlAssertGrep "^commit: ${commit}\$" $rlRun_LOG
      rlAssertGrep "^short-hash: ${short_hash}\$" $rlRun_LOG
      rlAssertGrep "^describe: ${describe}\$" $rlRun_LOG
      rlAssertGrep "^distance: ${distance}\$" $rlRun_LOG
    rlPhaseEnd

    rlPhaseStartTest "Off-tag: Build [${mode}]"
      rlRun "touch ./random_file" 0 "Create a random file"
      rlRun "git add random_file" 0 "Git add the random file"
      rlRun "git commit -m 'Moved commit'" 0 "Git commit (off-tag)"
      rlRun "commit=\$(git rev-parse HEAD) && echo \${commit}" 0 "Get git commit"
      rlRun "short_hash=\$(git rev-parse --short HEAD) && echo \${short_hash}" 0 "Get git short-hash"
      rlRun "describe=\$(git describe --tags --long) && echo \${describe}" 0 "Get git describe"
      rlRun "distance=\$(echo \${describe} | sed -E 's/.*-([0-9]+)-.*/\1/') && echo \${distance}" 0 "Extract git distance"
      rlRun "version_full=\$(hatch version ${hatch_args:-""}) && echo \${version_full}" 0 "Get setuptools_scm version"
      rlRun "version=\$(echo \${version_full} | sed -E 's/([0-9\.]*)\.[a-z].*/\1/') && echo \${version}" 0 "Strip version"
      # Check if it re-configured due to version change
      rlRun -s "cmake ${build_args} -t version" 0 "CMake build (version) 1st"
      rlAssertNotGrep "Re-running CMake" $rlRun_LOG
      rlRun -s "cmake ${build_args} -t version" 0 "CMake build (version) 2nd"
      if [[ ${mode} == DEV ]]; then
        # Version changed to guess the next version
        rlAssertGrep "Re-running CMake" $rlRun_LOG
        rlAssertGrep "^version: ${version}\$" $rlRun_LOG
        rlAssertGrep "version-full: ${version_full}" $rlRun_LOG -F
        rlAssertGrep "^commit: ${commit}\$" $rlRun_LOG
        rlAssertGrep "^short-hash: ${short_hash}\$" $rlRun_LOG
        rlAssertGrep "^describe: ${describe}\$" $rlRun_LOG
        rlAssertGrep "^distance: ${distance}\$" $rlRun_LOG
      else
        # Version did not change, it should not re-configure
        rlAssertNotGrep "Re-running CMake" $rlRun_LOG
      fi
      rlRun -s "${build_dir}/version" 0 "Run ./version"
      rlAssertGrep "^version: ${version}\$" $rlRun_LOG
      # If re-configured, the new version is version_full, otherwise use old version
      rlAssertGrep "version-full: $([ ${mode} == DEV ] && echo ${version_full} || echo ${tag_version})" $rlRun_LOG -F
      # Check if it re-configured due to commit change
      rlRun -s "cmake ${build_args} -t commit" 0 "CMake build (commit) 1st"
      rlAssertNotGrep "Re-running CMake" $rlRun_LOG
      rlRun -s "cmake ${build_args} -t commit" 0 "CMake build (commit) 2nd"
      if [[ ${mode} == DEV ]]; then
        # Already reconfigured because version changed
        rlAssertNotGrep "Re-running CMake" $rlRun_LOG
      else
        # Commit changed, it should re-configure
        rlAssertGrep "Re-running CMake" $rlRun_LOG
        rlAssertGrep "^version: ${version}\$" $rlRun_LOG
        rlAssertGrep "version-full: ${version_full}" $rlRun_LOG -F
        rlAssertGrep "^commit: ${commit}\$" $rlRun_LOG
        rlAssertGrep "^short-hash: ${short_hash}\$" $rlRun_LOG
        rlAssertGrep "^describe: ${describe}\$" $rlRun_LOG
        rlAssertGrep "^distance: ${distance}\$" $rlRun_LOG
      fi
      rlRun -s "${build_dir}/commit" 0 "Run ./commit"
      rlAssertGrep "^version: ${version}\$" $rlRun_LOG
      rlAssertGrep "version-full: ${version_full}" $rlRun_LOG -F
      rlAssertGrep "^commit: ${commit}\$" $rlRun_LOG
      rlAssertGrep "^short-hash: ${short_hash}\$" $rlRun_LOG
      rlAssertGrep "^describe: ${describe}\$" $rlRun_LOG
      rlAssertGrep "^distance: ${distance}\$" $rlRun_LOG
    rlPhaseEnd

    rlPhaseStartTest "New tag: Build [${mode}]"
      rlRun "tag_version='0.1.0'" 0 "Set tag_version"
      rlRun "git tag v\${tag_version}" 0 "Tag commit"
      rlRun "describe=\$(git describe --tags --long) && echo \${describe}" 0 "Get git describe"
      rlRun "distance=\$(echo \${describe} | sed -E 's/.*-([0-9]+)-.*/\1/') && echo \${distance}" 0 "Extract git distance"
      rlRun "version_full=\$(hatch version ${hatch_args:-""}) && echo \${version_full}" 0 "Get setuptools_scm version"
      # Commit did not change, it should not re-configure
      rlRun -s "cmake ${build_args} -t commit" 0 "CMake build (commit) 1st"
      rlAssertNotGrep "Re-running CMake" $rlRun_LOG
      rlRun -s "cmake ${build_args} -t commit" 0 "CMake build (commit) 2nd"
      rlAssertNotGrep "Re-running CMake" $rlRun_LOG
      rlRun -s "${build_dir}/commit" 0 "Run ./commit"
      rlAssertGrep "^commit: ${commit}\$" $rlRun_LOG
      # Version changed, it should re-configure
      rlRun -s "cmake ${build_args} -t version" 0 "CMake build (version) 1st"
      rlAssertNotGrep "Re-running CMake" $rlRun_LOG
      rlRun -s "cmake ${build_args} -t version" 0 "CMake build (version) 2nd"
      rlAssertGrep "Re-running CMake" $rlRun_LOG
      rlAssertGrep "^version: ${tag_version}\$" $rlRun_LOG
      rlAssertGrep "version-full: ${version_full}" $rlRun_LOG -F
      rlAssertGrep "^commit: ${commit}\$" $rlRun_LOG
      rlAssertGrep "^short-hash: ${short_hash}\$" $rlRun_LOG
      rlAssertGrep "^describe: ${describe}\$" $rlRun_LOG
      rlAssertGrep "^distance: ${distance}\$" $rlRun_LOG
      rlRun -s "${build_dir}/version" 0 "Run ./version"
      rlAssertGrep "^version: ${tag_version}\$" $rlRun_LOG
      # Check the version and describe again for completeness
      rlRun -s "cmake ${build_args} -t commit" 0 "CMake build (commit) 3rd"
      rlAssertNotGrep "Re-running CMake" $rlRun_LOG
      rlRun -s "${build_dir}/commit" 0 "Run ./commit"
      rlAssertGrep "^version: ${tag_version}\$" $rlRun_LOG
      rlAssertGrep "version-full: ${version_full}" $rlRun_LOG -F
      rlAssertGrep "^commit: ${commit}\$" $rlRun_LOG
      rlAssertGrep "^short-hash: ${short_hash}\$" $rlRun_LOG
      rlAssertGrep "^describe: ${describe}\$" $rlRun_LOG
      rlAssertGrep "^distance: ${distance}\$" $rlRun_LOG
    rlPhaseEnd
	done

	rlPhaseStartCleanup
		rlRun "popd"
		rlRun "rm -r $tmp" 0 "Remove tmp directory"
	rlPhaseEnd
rlJournalEnd
