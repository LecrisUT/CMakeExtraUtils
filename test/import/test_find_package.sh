#!/bin/bash -eux

tmp=$(mktemp -d)
rsync -r ./ $tmp
cd $tmp
cmake -B ./build . -DFETCHCONTENT_TRY_FIND_PACKAGE_MODE=OPT_IN
