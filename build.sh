#!/bin/bash

set -eaux

cd /build
sudo rm -rf trunk
tar xf build_NAS542.tar.gz
cd trunk

for patch in $(find ../patches/pre-world -type f -name "*.patch"); do
    patch -p1 < $patch
done

sudo ./mk542.sh world.gpl

for patch in $(find ../patches/post-world -type f -name "*.patch"); do
    patch -p1 < $patch
done

sudo ./mk542.sh ras.gpl
