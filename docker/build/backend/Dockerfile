FROM alpine:latest AS release
RUN apk add --no-cache git

ARG GIT_REVISION
ARG GIT_REPO_URL

WORKDIR /root/

RUN set -ex \
  && git clone $GIT_REPO_URL release -b $GIT_REVISION --depth 1


FROM ruby:3.3.14

COPY docker-entrypoint.sh /usr/local/bin
COPY --from=release /root/release /usr/src/app


RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    locales \
  && rm -rf /var/lib/apt/lists/* \
  && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen \
  && locale-gen en_US.UTF-8 \
  && sed -i 's,^\(MinProtocol[ ]*=\).*,\1'TLSv1.0',g' /etc/ssl/openssl.cnf \
  && sed -i 's,^\(CipherString[ ]*=\).*,\1'DEFAULT@SECLEVEL=1',g' /etc/ssl/openssl.cnf

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en

# timezone env with default
ENV TZ=Europe/Stockholm

WORKDIR /usr/src/app

RUN bundle install

EXPOSE 3000

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
