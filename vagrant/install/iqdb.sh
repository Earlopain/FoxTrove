#!/usr/bin/env bash

apt-get install -y libsqlite3-dev libgd-dev

git clone https://github.com/danbooru/iqdb.git /tmp/iqdb
cd /tmp/iqdb
cmake --preset release .
cmake --build .
cp /tmp/iqdb/src/iqdb /usr/local/bin/
