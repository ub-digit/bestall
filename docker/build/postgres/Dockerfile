FROM alpine:latest AS release
RUN apk add --no-cache git

ARG GIT_REVISION
ARG GIT_REPO_URL

WORKDIR /root/

RUN set -ex \
  && git clone $GIT_REPO_URL release -b $GIT_REVISION --depth 1

WORKDIR release/solr/config

FROM postgres:9.4

COPY --from=release /root/release/docker/build/postgres/postgres.conf /etc/postgresql/postgresql.conf
