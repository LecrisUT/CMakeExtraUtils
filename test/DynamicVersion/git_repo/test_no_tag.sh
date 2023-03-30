#!/bin/bash -eux

tmp=$(mktemp -d)
rsync -r ./ $tmp
cd $tmp
git init
git add CMakeLists.txt
git commit -m "Initial commit"
cmake -B ./build .
