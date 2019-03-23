#!/usr/bin/env bash

set -x

BUILD_DIR=$(nix-build)

cp -r "$BUILD_DIR" ./deploy
cd deploy

git init
git config user.email "nix-autobuild@huang-hobbs.co"
git config user.name "nix-autobuild"
git config http.sslVerify false
git add * > /dev/null
git commit -am "automatic-build at `date`"
git remote add 

set +x
set -e

git push --force --quiet \
    https://${GITHUB_TOKEN}:x-oauth-basic@${GITHUB_REMOTE} master:gh-pages

