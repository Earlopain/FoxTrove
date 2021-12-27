puma: bin/rails server -p 9000 -b 0.0.0.0
js: yarn build --watch
css: yarn build:css --watch
tsc: yarn tsc --watch --preserveWatchOutput
scraping: bundle exec sidekiq -c 1 -q scraping
download: bundle exec sidekiq -c 5 -q submission_download
variants: bundle exec sidekiq -c 10 -q variant_generation
