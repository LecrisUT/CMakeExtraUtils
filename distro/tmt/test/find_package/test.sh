#!/bin/sh -eux

tmp=$(mktemp -d)
cmake -B $tmp -S .
rm -r $tmp
