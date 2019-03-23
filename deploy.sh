#!/usr/bin/env bash

set -ex

BUILD_DIR=$(nix-build)

cd `mktemp -d`
cp -r "$BUILD_DIR" ./deploy
cd deploy

ls -la

GIT="git -c user.email=\"nix-autobuild@huang-hobbs.co\" \
    -c user.name=\"nix-autobuild\" \
    "

$GIT init
$GIT add *
$GIT commit -am "automatic-build at `date`"

$GIT push --force --quiet \
    https://${GITHUB_TOKEN}:x-oauth-basic@${GITHUB_REMOTE} master:gh-pages

