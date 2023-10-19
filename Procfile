puma: bin/rails server -p 9000 -b 0.0.0.0
frontend: esbuild app/typescript/application.ts --target=chrome111,firefox111,safari16 --bundle --sourcemap --outdir=public/build --loader:.png=file --watch=forever --color=true
good_job: bundle exec good_job --queues="scraping:1;e6_iqdb:1;variant_generation:5;default:1;submission_download:5"
