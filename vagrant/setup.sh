#!/usr/bin/env bash

APP_DIR=/vagrant
CHRUBY_PATH=/etc/profile.d/chruby.sh
USER=reverser

apt-get update

package_installed() {
    if dpkg-query -f '${binary:Package}\n' -W | grep "$1" &>/dev/null; then
        return 0;
    else
        return 1;
    fi
}

add_key() {
    wget -qO - "$1" | sudo apt-key add - &>/dev/null
}

script_log() {
    echo "[install.sh] >>> $@"
}

if ! grep $USER /etc/passwd >/dev/null; then
    script_log "Creating system user..."
    useradd -m -s /bin/bash -U $USER
    cp -pr /home/vagrant/.ssh /home/$USER/
    chown -R $USER:$USER /home/$USER/.ssh
    echo "%$USER ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/$USER
    usermod -aG vagrant,www-data $USER
fi

if ! package_installed postgresql-13; then
    add_key https://www.postgresql.org/media/keys/ACCC4CF8.asc
    echo "deb https://apt.postgresql.org/pub/repos/apt/ focal-pgdg main" > /etc/apt/sources.list.d/pgdg.list
    script_log "PostgreSQL repository added"
fi

if ! package_installed nodejs; then
    wget -qO - https://deb.nodesource.com/setup_14.x | sudo -E bash - >/dev/null 2>&1
    script_log "Node.js repository added"
fi

if ! package_installed yarn; then
    add_key https://dl.yarnpkg.com/debian/pubkey.gpg
    echo "deb https://dl.yarnpkg.com/debian/ stable main" > /etc/apt/sources.list.d/yarn.list
    script_log "yarn repository added"
fi

if ! package_installed redis-server; then
   add-apt-repository -y ppa:redislabs/redis
   script_log "redis repository added"
fi

apt-get update

# build dependencies
apt-get install -y cmake pkg-config libglib2.0-dev libexpat1-dev

# runtime dependencies
apt-get install -y postgresql-13 postgresql-server-dev-13 redis-server nodejs yarn nginx

script_log "Setting up postgres..."
sed -i -e 's/md5/trust/' /etc/postgresql/13/main/pg_hba.conf

service postgresql restart

script_log "Creating postgres user..."
sudo -u postgres createuser -s $USER

if ! which vipsthumbnail >/dev/null; then
    script_log "Installing libvips..."
    VIPS_VERSION=8.11.3
    pushd .
    cd /tmp
    wget -q https://github.com/libvips/libvips/releases/download/v$VIPS_VERSION/vips-$VIPS_VERSION.tar.gz
    tar xf vips-$VIPS_VERSION.tar.gz
    cd vips-$VIPS_VERSION
    ./configure --prefix=/usr
    make install
    ldconfig
    popd
    rm -fr /tmp/vips-$VIPS_VERSION.tar.gz /tmp/vips-$VIPS_VERSION
fi

if ! type ruby-install >/dev/null 2>&1; then
    script_log "Installing ruby-install..."
    RUBY_INSTALL_VERSION=0.8.2
    cd /usr/local/src
    wget -qO ruby-install-$RUBY_INSTALL_VERSION.tar.gz https://github.com/postmodern/ruby-install/archive/v$RUBY_INSTALL_VERSION.tar.gz
    tar -xzvf ruby-install-$RUBY_INSTALL_VERSION.tar.gz >/dev/null
    cd ruby-install-$RUBY_INSTALL_VERSION/
    sudo make install >/dev/null
    rm /usr/local/src/ruby-install-$RUBY_INSTALL_VERSION.tar.gz
fi

if [ -f "$CHRUBY_PATH" ]; then
    source $CHRUBY_PATH
fi

if ! type chruby >/dev/null 2>&1; then
    script_log "Installing chruby..."
    CHRUBY_VERSION=0.3.9
    cd /usr/local/src
    wget -qO chruby-$CHRUBY_VERSION.tar.gz https://github.com/postmodern/chruby/archive/v$CHRUBY_VERSION.tar.gz
    tar -xzvf chruby-$CHRUBY_VERSION.tar.gz >/dev/null
    cd chruby-$CHRUBY_VERSION/
    sudo make install >/dev/null
    sudo ./scripts/setup.sh >/dev/null
    rm /usr/local/src/chruby-$CHRUBY_VERSION.tar.gz

    echo -e \
"if [ -n \"\$BASH_VERSION\" ] || [ -n \"\$ZSH_VERSION\" ]; then
  source /usr/local/share/chruby/chruby.sh
  source /usr/local/share/chruby/auto.sh
fi" > $CHRUBY_PATH
fi

if ! which iqdb >/dev/null; then
    script_log "Installing iqdb..."
    bash $APP_DIR/vagrant/install/iqdb.sh
fi

script_log "Enabling redis server..."
systemctl enable redis-server 2>/dev/null
systemctl start redis-server

script_log "Stopping systemd service..."
service reverser stop 2>/dev/null

sudo -i -u $USER bash -c "$APP_DIR/vagrant/user-setup.sh '$APP_DIR' '$CHRUBY_PATH'"


script_log "Enabling nginx..."
cp $APP_DIR/vagrant/nginx.conf /etc/nginx/conf.d/reverser.conf
service nginx restart

script_log "Installing shoreman..."
curl https://github.com/chrismytton/shoreman/raw/master/shoreman.sh -sLo /usr/bin/shoreman
chmod +x /usr/bin/shoreman

script_log "Copying systemd unit file..."
cp $APP_DIR/vagrant/reverser.service /lib/systemd/system/
systemctl daemon-reload
systemctl enable reverser 2>/dev/null

script_log "Restarting systemd service..."
service reverser restart
