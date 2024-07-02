FROM ruby:3.3.3-alpine3.20 AS ruby-builder

RUN apk --no-cache add build-base cmake postgresql16-dev

COPY Gemfile Gemfile.lock ./
RUN gem i foreman && bundle install \
 && rm -rf /usr/local/bundle/cache/*.gem \
 && find /usr/local/bundle/gems/ -name "*.c" -delete \
 && find /usr/local/bundle/gems/ -name "*.o" -delete

FROM node:20-alpine3.20 AS node-downloader

RUN npm install esbuild@0.21.5 -g

FROM ruby:3.3.3-alpine3.20

WORKDIR /app

RUN apk --no-cache add \
  tzdata \
  postgresql16-client \
  vips ffmpeg \
  sudo jemalloc

ENV LD_PRELOAD=/usr/lib/libjemalloc.so.2
ENV RUBY_YJIT_ENABLE=1

# Create a user with (potentially) the same id as on the host
ARG HOST_UID
ARG HOST_GID
RUN addgroup --gid ${HOST_GID} reverser && \
  adduser -S --shell /bin/sh --uid ${HOST_UID} reverser -G reverser && \
  addgroup reverser wheel && \
  echo "reverser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
ARG DOCKER_RUN_AS_USER
ENV USER=${DOCKER_RUN_AS_USER:+reverser}
ENV USER=${USER:-root}
USER $USER

# Copy native npm package binaries
COPY --from=node-downloader /usr/local/lib/node_modules/esbuild/bin/esbuild /usr/local/bin

# Copy gems
COPY --from=ruby-builder /usr/local/bundle /usr/local/bundle

# Bust cache if local git ref changes and add it to the image
# This looks weird but handles the .git folder missing entirely
ADD .gi?/ref?/head?/maste? /docker/git_master_ref
