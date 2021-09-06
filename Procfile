unicorn: bin/rails server -p 9000
jobs: bundle exec sidekiq -c 1 -q default
iqdb: iqdb http 0.0.0.0 5588 /home/reverser/iqdb.db
nginx: nginx -c /vagrant/vagrant/nginx.conf -e /home/reverser/nginx.err
redis: redis-server
postgres: sudo mkdir -p /var/run/postgresql && sudo chown reverser:reverser /var/run/postgresql && /usr/lib/postgresql/13/bin/postgres -D /home/reverser/postgres
