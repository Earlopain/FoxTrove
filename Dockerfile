FROM ruby:3.1.2-alpine

WORKDIR /app

# TODO: use node provided corepack when available
RUN apk --no-cache add \
  tzdata build-base git \
  nodejs npm \
  postgresql-client libpq-dev \
  vips \
  ffmpeg \
  && npm install -g corepack \
  && corepack prepare yarn@3.2.1 --activate

RUN git config --global --add safe.directory /app

COPY package.json yarn.lock .yarnrc.yml ./
RUN yarn install

COPY Gemfile Gemfile.lock ./
RUN gem i bundler:2.3.15 foreman && BUNDLE_WITHOUT=local:rubocop bundle install

RUN echo "IRB.conf[:USE_AUTOCOMPLETE] = false" > ~/.irbrc

CMD foreman start
