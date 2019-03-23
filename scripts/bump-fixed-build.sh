#!/usr/bin/env bash


echo $PATH | tr ':' '\n'

set -ex

nix-prefetch-github adjective-object blog > ./fixed-version.json