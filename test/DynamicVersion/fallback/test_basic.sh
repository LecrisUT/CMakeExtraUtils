#!/bin/bash -eux

tmp=$(mktemp -d)
rsync -r ./ $tmp
cd $tmp
cmake -B ./build .
