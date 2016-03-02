#/usr/bin/env bash

dest=$1
if [ "$dest" == "" ]; then 
    dest=_site;
fi

echo "deploying from $dest"
cd $dest


git init
git config user.email "nix-autobuild@huang-hobbs.co"
git config quiet user.name "nix-autobuild"
git config quiet http.sslVerify false
git add quiet . > /dev/null
git commit -am "Nix-build at `time`"

GH_REMOTE=github.com/Adjective-Object/blog.git
source ./github_token
git push --force quiet https://${GH_TOKEN}@${GH_REMOTE} master:gh-pages > /dev/null

