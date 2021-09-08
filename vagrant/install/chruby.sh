#!/usr/bin/env bash

CHRUBY_VERSION=$1
cd /tmp
wget -qO chruby-$CHRUBY_VERSION.tar.gz https://github.com/postmodern/chruby/archive/v$CHRUBY_VERSION.tar.gz
tar -xzvf chruby-$CHRUBY_VERSION.tar.gz
cd chruby-$CHRUBY_VERSION/
sudo make install
sudo ./scripts/setup.sh

echo -e \
"if [ -n \"\$BASH_VERSION\" ] || [ -n \"\$ZSH_VERSION\" ]; then
  source /usr/local/share/chruby/chruby.sh
  source /usr/local/share/chruby/auto.sh
fi" > $2
