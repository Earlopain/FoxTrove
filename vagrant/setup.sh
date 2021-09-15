#!/usr/bin/env bash

APP_DIR=/vagrant
CHRUBY_PATH=/etc/profile.d/chruby.sh
USER=reverser

CHRUBY_VERSION=0.3.9
RUBY_INSTALL_VERSION=0.8.2
VIPS_VERSION=8.11.3
POSTGRESQL_VERSION=13
NODE_VERSION=16

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

if ! package_installed postgresql-$POSTGRESQL_VERSION; then
    add_key https://www.postgresql.org/media/keys/ACCC4CF8.asc
    echo "deb https://apt.postgresql.org/pub/repos/apt/ focal-pgdg main" > /etc/apt/sources.list.d/pgdg.list
    script_log "PostgreSQL repository added"
fi

if ! package_installed nodejs; then
    wget -qO - https://deb.nodesource.com/setup_$NODE_VERSION.x | sudo -E bash - >/dev/null 2>&1
    script_log "Node.js repository added"
fi

if ! package_installed redis-server; then
   add-apt-repository -y ppa:redislabs/redis
   script_log "redis repository added"
fi

# nginx -e was added in 1.20 while ubuntu still ships 1.18
if ! package_installed nginx; then
    add_key http://nginx.org/keys/nginx_signing.key
    echo "deb https://nginx.org/packages/ubuntu/ focal nginx" > /etc/apt/sources.list.d/nginx.list
    script_log "nginx repository added"
fi

apt-get update

# build dependencies
apt-get install -y build-essential pkg-config libglib2.0-dev libexpat1-dev

# runtime dependencies
apt-get install -y postgresql-$POSTGRESQL_VERSION postgresql-server-dev-$POSTGRESQL_VERSION redis-server nodejs nginx
npm install --global yarn

script_log "Setting up postgres..."
sed -i -e 's/md5/trust/' /etc/postgresql/$POSTGRESQL_VERSION/main/pg_hba.conf

# allow connections from the host machine
if ! grep -q "192" "/etc/postgresql/$POSTGRESQL_VERSION/main/pg_hba.conf"; then
  echo "host all all 192.168.64.1/32 trust" >> /etc/postgresql/$POSTGRESQL_VERSION/main/pg_hba.conf
fi

# listen for outside connections
echo "listen_addresses = '*'" > /etc/postgresql/$POSTGRESQL_VERSION/main/conf.d/listen_addresses.conf

systemctl restart postgresql
sudo -u postgres createuser -s $USER

if ! which vipsthumbnail >/dev/null; then
    script_log "Installing libvips..."
    bash $APP_DIR/vagrant/install/vips.sh $VIPS_VERSION
fi

if ! type ruby-install >/dev/null 2>&1; then
    script_log "Installing ruby-install..."
    bash $APP_DIR/vagrant/install/ruby-install.sh $RUBY_INSTALL_VERSION
fi

if [ -f "$CHRUBY_PATH" ]; then
    source $CHRUBY_PATH
fi

if ! type chruby >/dev/null 2>&1; then
    script_log "Installing chruby..."
    bash $APP_DIR/vagrant/install/chruby.sh $CHRUBY_VERSION $CHRUBY_PATH
fi

if ! which iqdb >/dev/null; then
    script_log "Installing iqdb..."
    bash $APP_DIR/vagrant/install/iqdb.sh
fi

script_log "Enabling redis server..."
systemctl enable redis-server 2>/dev/null
systemctl start redis-server

script_log "Stopping system service..."
sudo systemctl stop reverser 2>/dev/null

sudo -i -u $USER bash -c "$APP_DIR/vagrant/user-setup.sh '$APP_DIR' '$CHRUBY_PATH'"

script_log "Setting up nginx..."
rm -f /etc/nginx/conf.d/default.conf
cp -rf $APP_DIR/vagrant/reverser.conf /etc/nginx/conf.d
systemctl restart nginx

script_log "Installing shoreman..."
curl https://github.com/chrismytton/shoreman/raw/master/shoreman.sh -sLo /usr/bin/shoreman
chmod +x /usr/bin/shoreman

script_log "Installing systemd unit file..."
cp $APP_DIR/vagrant/reverser.service /lib/systemd/system/
systemctl daemon-reload
systemctl enable reverser 2>/dev/null


script_log "Restarting systemd service..."
sudo systemctl restart reverser
