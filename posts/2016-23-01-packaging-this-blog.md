---
title: Packaging This Blog with Nix
---


As a learning experience, I decided I wanted to try to package this blog using 
nix. It seemed like it should be a simple enough task, and a good way to get 
started with packaging my personal projects.

# Creating a Local Repo
Most of the packaging guides for nix start with the assumption you intend to 
upstream your work to nixpkgs ASAP by working in a fork of the nixpkgs repo. 
I wanted a way to package my code that would:

1. Allow me to reliably rebuild it without network access (beyond the initial fetch)
2. Keep package files closely tied to the repositories they sit in
3. Eventually upstream it without changing the package's default.nix file
4. Be easy to maintain in the future


My personal projects are all held in a `Projects` directory with this rough 
structure:

~~~ 
~/Projects
├── blog
│   ├── default.nix
│   └── ...
└── other-project
    ├── default.nix
    └── ...
~~~


Taking advantage of this regular structure, I settled on the following 
expression


~~~ nix
# default to a local build
{isLocal ? true}:

let pkgs = import <nixpkgs> {};
    overrideDerivation = pkgs.stdenv.lib.overrideDerivation;
    localSourceRoot = /home/adjective/Projects;

    # if we are building from local source (development)
    # override the src property of the derivation
    # otherwise, leave it untouched
    overrideIfLocal = (localPath: old:
      let srcModification = (_ :if isLocal 
          then { src = localPath; }
          else {}
      );
      in overrideDerivation old srcModification 
    );

    # load a package and override it if we are
    # doing a local build
    loadPackage = (localPath:
      overrideIfLocal 
        localPath 
        (pkgs.callPackage ("${localPath}/default.nix") {})
    );

# list of projects that have been packaged so far
in with pkgs;
{
  blog = loadPackage ./blog;
}
~~~

this can be used to build any project as either a local or a networked build
with the command

~~~ bash
nix-env -f root.nix -i $project --arg isLocal true
nix-env -f root.nix -i $project --arg isLocal false
~~~

# Packaging the Blog

I already had a `shell.nix` file, so I the dependency resolution part of the 
packaging process was already done for me. Neat!

However, the peculiar way nix builds things to get reproducible outputs 
introduced some interesting issues.

## Hakyll, UTF-8, and locale
In order to handle utf-8 character encodings, hakyll site binaries require 
the user set a utf-8 compatible locale (e.g. `en_US-UTF8`.

I'm unfamiliar with how locale actually works in Linux. Normally I just set it
once when I install and forget about it. Apparently there's a series of Perl
scripts that manage your language settings for time formats, keyboard layout, 
etc. Some part of the mechanism requires a locale store, which is provided
as a part of `glibc`.

In order to fix this, we can add a dependency on glibc and point to the 
locale-archive before the site is built.

~~~ nix
  configurePhase = ''
    export LOCALE_ARCHIVE=${glibcLocales}/lib/locale/locale-archive
    export LANG=${buildLocale}
  '';
~~~


## Deploying with Git


# Future Work
## Continuous Integration

## Problems With Commit Hashes?

## 

# Thanks
[`clever`](https://github.com/cleverca22) for helping me struggle with the nix
language and nixpkgs stdlib

[`pxc`](https://github.com/therealpxc),
`gchristensen`, and 
[`Lethalman`](https://github.com/lethalman)
on the #nixos freenode channel for advice on how to manage a personal repos





 
