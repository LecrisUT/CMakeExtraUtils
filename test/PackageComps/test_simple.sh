#!/bin/bash -eux

tmp=$(mktemp -d)
rsync -r ./ $tmp
cd $tmp
cmake -B ./build_provider -S ./simple_provider -DCMAKE_INSTALL_PREFIX=install
cmake --build ./build_provider
cmake --install ./build_provider
cmake -B ./build_user -S ./simple_user -DTestProvider_ROOT="$(echo ./install/lib*/cmake/TestProvider)"
