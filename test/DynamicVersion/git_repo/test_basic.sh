#!/bin/bash -eux

tmp=$(mktemp -d)
rsync -r ./ $tmp
cd $tmp
git init
git add CMakeLists.txt
git commit -m "Initial commit"
git tag v0.0.0
cmake -B ./build .
