#!/usr/bin/env bash

set -e 

make
cd _site

git init
git config user.email "nix-autobuild@huang-hobbs.co"
git config user.name "nix-autobuild"
git config http.sslVerify false
git add * > /dev/null
git commit -am "automatic-build at `date`"

echo "pushing to github..."
git push --force --quiet \
  ${github_token}@${github_remote} master:gh-pages > /dev/null

