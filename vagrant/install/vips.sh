#!/usr/bin/env bash

VIPS_VERSION=$1

apt-get install liblcms2-dev libjpeg-turbo8-dev libpng-dev libwebp-dev

cd /tmp
wget -q https://github.com/libvips/libvips/releases/download/v$VIPS_VERSION/vips-$VIPS_VERSION.tar.gz
tar xf vips-$VIPS_VERSION.tar.gz
cd vips-$VIPS_VERSION
./configure --prefix=/usr
make install
ldconfig
