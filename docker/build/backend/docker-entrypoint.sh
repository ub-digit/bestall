#!/bin/bash
set -e

rm -f /usr/src/app/tmp/pids/server.pid

# Run bundle install before starting rails if local development environment
if [[ ("$1" == "rails" || ("$1" == "bundle" && $2 == "exec")) && ("$RAILS_ENV" == "development" || "$RAILS_ENV" = "test") ]]; then
  set -x
  bundle install --path vendor/bundle
  #bundle exec rake rails:update:bin
fi
exec "$@"
