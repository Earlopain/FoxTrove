FROM ruby:3.0.3-alpine

WORKDIR /app

RUN apk --no-cache add nodejs yarn postgresql-client vips tzdata build-base git libpq-dev nodejs yarn

COPY package.json yarn.lock .yarnrc.yml ./
COPY .yarn ./.yarn
RUN yarn install

COPY Gemfile Gemfile.lock ./
RUN bundle install && gem install foreman

CMD foreman start
