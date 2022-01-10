puma: bin/rails server -p 9000 -b 0.0.0.0
js: yarn build --watch --color=true
css: yarn build:css --watch --color
tsc: yarn tsc --watch --preserveWatchOutput --pretty
scraping: bundle exec sidekiq -c 1 -q scraping
e6_iqdb: bundle exec sidekiq -c 1 -q e6_iqdb
download: bundle exec sidekiq -c 5 -q submission_download
variants: bundle exec sidekiq -c 10 -q variant_generation
