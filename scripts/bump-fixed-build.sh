#!/usr/bin/env bash


echo $PATH | tr ':' '\n'

set -ex

nix-prefetch-git https://github.com/Adjective-Object/blog.git > ./fixed-version.json