#!/bin/bash

if test "$1" = ""
then
  echo Usage: $0 git-revision-tag
  exit
fi

git tag $1
git push origin $1
GIT_REVISION=$1 docker compose build
./push.sh $1
