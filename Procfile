puma: bin/rails server -p 9000 -b 0.0.0.0
js: pnpm run build:js --watch=forever --color=true
css: pnpm run build:css --watch=forever --color=true
tsc: pnpm run tsc --watch --preserveWatchOutput --pretty
good_job: bundle exec good_job --queues="scraping:1;e6_iqdb:1;variant_generation:5;default:1;submission_download:5"
