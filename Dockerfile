FROM ruby:3.0.3-alpine

WORKDIR /app

# TODO: use node provided corepack when available
RUN apk --no-cache add \
  tzdata build-base git \
  nodejs npm \
  postgresql-client libpq-dev \
  vips \
  ffmpeg \
  && npm install -g corepack \
  && corepack prepare yarn@3.1.1 --activate

COPY package.json yarn.lock .yarnrc.yml ./
RUN yarn install

COPY Gemfile Gemfile.lock ./
RUN bundle install && gem install foreman

CMD foreman start
