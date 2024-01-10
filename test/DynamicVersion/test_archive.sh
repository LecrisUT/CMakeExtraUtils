#!/bin/bash
# vim: dict+=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
. /usr/share/beakerlib/beakerlib.sh || exit 1

rlJournalStart
	rlPhaseStartSetup
		rlRun "tmp=\$(mktemp -d)" 0 "Create tmp directory"
		rlRun "rsync -r ./ $tmp" 0 "Copy test files"
		rlRun "pushd $tmp"
    rlRun "base_configure_args=\"-G Ninja --log-context\"" 0 "Set base_configure_args"
    [[ -n "$CMakeExtraUtils_ROOT" ]] && rlRun "base_configure_args=\"\${base_configure_args} -DCMakeExtraUtils_ROOT=\${CMakeExtraUtils_ROOT}\"" 0 "Add CMakeExtraUtils_ROOT"
    rlRun "echo '.git_archival.txt  export-subst' > .gitattributes" 0 "Configure .gitattributes"
		rlRun "set -o pipefail"
		rlIsCentOS && rlRun "export PYTHONWARNINGS=\"ignore::RuntimeWarning\" && hatch_args=\"2>&1\"" 0 "Workaround for hatch/setuptools_scm issue"
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
      rlRun "git init"
      rlRun "git add CMakeLists.txt .git_archival.txt .gitattributes src pyproject.toml" 0 "Git add basic files"
      rlRun "git commit -m 'Initial commit'" 0 "Git commit (initial)"
	  rlPhaseEnd

    rlPhaseStartTest "No tag created: Should fail [${mode}]"
      [[ -d ${build_dir} ]] && rlRun "rm -rf ${build_dir}" 0 "Clean the build directory"
      rlRun "archive_name='no_tag'" 0 "Set archive_name"
      rlRun "git archive HEAD --prefix=${archive_name}/ -o ${archive_name}.tar.gz" 0 "Git archive"
      rlRun "tar -xf ${archive_name}.tar.gz" 0 "Extract archive"
      rlRun -s "cmake -S ${archive_name} ${configure_args}" 1 "CMake configure"
      # TODO: Missing appropriate rlAssertGrep
    rlPhaseEnd

    rlPhaseStartTest "Tagged archive [${mode}]"
      [[ -d ${build_dir} ]] && rlRun "rm -rf ${build_dir}" 0 "Clean the build directory"
      rlRun "archive_name='tagged'" 0 "Set archive_name"
      rlRun "tag_version=0.0.0" 0 "Set tag_version"
      rlRun "git tag v\${tag_version}" 0 "Tag git commit"
      rlRun "commit=\$(git rev-parse HEAD) && echo \${commit}" 0 "Get git commit"
      rlRun "short_hash=\$(git rev-parse --short HEAD) && echo \${short_hash}" 0 "Get git short-hash"
      rlRun "describe=\$(git describe --tags) && echo \${describe}" 0 "Get git describe"
      # On tag, distance == 0
      rlRun "distance=0 && echo \${distance}" 0 "Extract git distance"
      rlRun "git archive HEAD --prefix=${archive_name}/ -o ${archive_name}.tar.gz" 0 "Git archive"
      rlRun "tar -xf ${archive_name}.tar.gz" 0 "Extract archive"
		  rlIsCentOS && rlRun "echo \$(cd ${archive_name} && hatch version)" 0 "Setup hatch environment"
      rlRun "version_full=\$(cd ${archive_name} && hatch version ${hatch_args:-""}) && echo \${version_full}" 0 "Get setuptools_scm version"
      rlRun -s "cmake -S ${archive_name} ${configure_args}" 0 "CMake configure"
      rlAssertGrep "^\[TestProject\] version: ${tag_version}\$" $rlRun_LOG
      rlAssertGrep "^\[TestProject\] version-full: ${version_full}\$" $rlRun_LOG
      rlAssertGrep "^\[TestProject\] commit: ${commit}\$" $rlRun_LOG
      # In this case, we set short-hash-NOTFOUND because it is not available in git describe
      rlAssertGrep "^\[TestProject\] short-hash: short-hash-NOTFOUND\$" $rlRun_LOG
      rlAssertGrep "^\[TestProject\] describe: ${describe}\$" $rlRun_LOG
      rlAssertGrep "^\[TestProject\] distance: ${distance}\$" $rlRun_LOG
      rlRun -s "cmake ${build_args}" 0 "CMake build"
      rlRun -s "${build_dir}/version" 0 "Run ./version"
      rlAssertGrep "^version: ${tag_version}\$" $rlRun_LOG
      rlAssertGrep "^version-full: ${version_full}\$" $rlRun_LOG
      rlRun -s "${build_dir}/commit" 0 "Run ./commit"
      rlAssertGrep "^version: ${tag_version}\$" $rlRun_LOG
      rlAssertGrep "^version-full: ${version_full}\$" $rlRun_LOG
      rlAssertGrep "^commit: ${commit}\$" $rlRun_LOG
      # In this case, we set short-hash-NOTFOUND because it is not available in git describe
      rlAssertGrep "^short-hash: short-hash-NOTFOUND\$" $rlRun_LOG
      rlAssertGrep "^describe: ${describe}\$" $rlRun_LOG
      rlAssertGrep "^distance: ${distance}\$" $rlRun_LOG
    rlPhaseEnd

    rlPhaseStartTest "Off-tag archive [${mode}]"
      [[ -d ${build_dir} ]] && rlRun "rm -rf ${build_dir}" 0 "Clean the build directory"
      rlRun "archive_name='off-tag'" 0 "Set archive_name"
      rlRun "touch ./random_file" 0 "Create a random file"
      rlRun "git add random_file" 0 "Git add the random file"
      rlRun "git commit -m 'Moved commit'" 0 "Git commit (off-tag)"
      rlRun "commit=\$(git rev-parse HEAD) && echo \${commit}" 0 "Get git commit"
      rlRun "short_hash=\$(git rev-parse --short HEAD) && echo \${short_hash}" 0 "Get git short-hash"
      rlRun "describe=\$(git describe --tags) && echo \${describe}" 0 "Get git describe"
      rlRun "distance=\$(echo \${describe} | sed -E 's/.*-([0-9]+)-.*/\1/') && echo \${distance}" 0 "Extract git distance"
      rlRun "git archive HEAD --prefix=${archive_name}/ -o ${archive_name}.tar.gz" 0 "Git archive"
      rlRun "tar -xf ${archive_name}.tar.gz" 0 "Extract archive"
		  rlIsCentOS && rlRun "echo \$(cd ${archive_name} && hatch version)" 0 "Setup hatch environment"
      rlRun "version_full=\$(cd ${archive_name} && hatch version ${hatch_args:-""}) && echo \${version_full}" 0 "Get setuptools_scm version"
      rlRun "version=\$(echo \${version_full} | sed -E 's/([0-9\.]*)\.[a-z].*/\1/') && echo \${version}" 0 "Strip version"
      rlRun -s "cmake -S ${archive_name} ${configure_args}" 0 "CMake configure"
      rlAssertGrep "^\[TestProject\] version: ${version}\$" $rlRun_LOG
      rlAssertGrep "^\[TestProject\] version-full: ${version_full}\$" $rlRun_LOG
      rlAssertGrep "^\[TestProject\] commit: ${commit}\$" $rlRun_LOG
      rlAssertGrep "^\[TestProject\] short-hash: ${short_hash}\$" $rlRun_LOG
      rlAssertGrep "^\[TestProject\] describe: ${describe}\$" $rlRun_LOG
      rlAssertGrep "^\[TestProject\] distance: ${distance}\$" $rlRun_LOG
      rlRun -s "cmake ${build_args}" 0 "CMake build"
      rlRun -s "${build_dir}/version" 0 "Run ./version"
      rlAssertGrep "^version: ${version}\$" $rlRun_LOG
      rlAssertGrep "version-full: ${version_full}" $rlRun_LOG -F
      rlRun -s "${build_dir}/commit" 0 "Run ./commit"
      rlAssertGrep "^version: ${version}\$" $rlRun_LOG
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
