#!/usr/bin/env bash

RUBY_INSTALL_VERSION=0.8.2
cd /usr/local/src
wget -qO ruby-install-$RUBY_INSTALL_VERSION.tar.gz https://github.com/postmodern/ruby-install/archive/v$RUBY_INSTALL_VERSION.tar.gz
tar -xzvf ruby-install-$RUBY_INSTALL_VERSION.tar.gz
cd ruby-install-$RUBY_INSTALL_VERSION/
make install
