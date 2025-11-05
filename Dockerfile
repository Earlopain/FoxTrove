ARG BASE_IMAGE
FROM ${BASE_IMAGE:-ruby:3.4.7-alpine3.22} AS ruby-builder

RUN apk --no-cache add build-base cmake git \
  libffi-dev postgresql17-dev yaml-dev

COPY Gemfile Gemfile.lock ./
RUN gem i foreman && bundle install \
 && rm -rf /usr/local/bundle/cache/*.gem \
 && find /usr/local/bundle/gems/ -name "*.c" -delete \
 && find /usr/local/bundle/gems/ -name "*.o" -delete

FROM node:24-alpine3.22 AS node-downloader

RUN npm install esbuild@0.25.12 -g

FROM ${BASE_IMAGE:-ruby:3.4.7-alpine3.22}

WORKDIR /app

RUN apk --no-cache add \
  tzdata \
  postgresql17-client \
  vips ffmpeg \
  sudo jemalloc

ENV LD_PRELOAD=/usr/lib/libjemalloc.so.2
ENV RUBYOPT=--enable=frozen-string-literal

RUN echo "[safe]" > ~/.gitconfig && \
  echo "        directory = /app" >> ~/.gitconfig

# Create a user with (potentially) the same id as on the host
ARG HOST_UID=1000
ARG HOST_GID=1000
RUN addgroup --gid ${HOST_GID} foxtrove && \
  adduser -S --shell /bin/sh --uid ${HOST_UID} foxtrove -G foxtrove && \
  addgroup foxtrove wheel && \
  echo "foxtrove ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
ARG DOCKER_RUN_AS_USER
ENV USER=${DOCKER_RUN_AS_USER:+foxtrove}
ENV USER=${USER:-root}
USER $USER

# Copy native npm package binaries
COPY --from=node-downloader /usr/local/lib/node_modules/esbuild/bin/esbuild /usr/local/bin

# Copy gems
COPY --from=ruby-builder /usr/local/bundle /usr/local/bundle

# Bust cache if local git ref changes and add it to the image
# This looks weird but handles the .git folder missing entirely
ADD .gi?/ref?/head?/maste? /docker/git_master_ref
