#!/usr/bin/env bash

script_log() {
    echo -e "[user-setup.sh] >>> $@"
}

APP_DIR=$1
CHRUBY_PATH=$2

source $CHRUBY_PATH

RUBY_VER_NUM=$(cat $APP_DIR/.ruby-version)
RUBY_VER="ruby-$RUBY_VER_NUM"

cd $APP_DIR

if ! command -v ruby >/dev/null || ruby -v | grep -v "$RUBY_VER_NUM" >/dev/null 2>&1; then
    echo "Downloading, compiling and installing $RUBY_VER... (this will take a while)"
    ruby-install $RUBY_VER
    source $CHRUBY_PATH
    chruby $RUBY_VER
    script_log "Installed ruby version: $(ruby -v)"
fi

script_log "Installing bundler gem..."
gem install bundler >/dev/null
bundler config github.https true

script_log "Restarting systemd service..."
sudo systemctl restart reverser

# Race condition: If postgres did not fully start yet
script_log "Running setup..."
./bin/setup
