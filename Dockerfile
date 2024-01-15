FROM ruby:3.2.2-alpine3.19 as ruby-builder

RUN apk --no-cache add build-base postgresql16-dev

COPY Gemfile Gemfile.lock ./
RUN gem i foreman && bundle install \
 && rm -rf /usr/local/bundle/cache/*.gem \
 && find /usr/local/bundle/gems/ -name "*.c" -delete \
 && find /usr/local/bundle/gems/ -name "*.o" -delete

FROM node:20-alpine3.19 as node-downloader

RUN npm install esbuild@0.19.8 -g

FROM ruby:3.2.2-alpine3.19

WORKDIR /app

RUN apk --no-cache add \
  tzdata git \
  postgresql16-client \
  vips ffmpeg \
  sudo

RUN git config --global --add safe.directory /app

# Create a user with (potentially) the same id as on the host
ARG HOST_UID=1000
ARG HOST_GID=1000
RUN addgroup --gid ${HOST_GID} reverser && \
  adduser -S --shell /bin/sh --uid ${HOST_UID} reverser && \
  addgroup reverser wheel && \
  echo "reverser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Copy native npm package binaries
COPY --from=node-downloader /usr/local/lib/node_modules/esbuild/bin/esbuild /usr/local/bin

# Copy gems
COPY --from=ruby-builder /usr/local/bundle /usr/local/bundle
