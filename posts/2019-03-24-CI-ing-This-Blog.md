---
title: ⚒ CI-ing This Blog
tags: notion, meta, haskell, nix
---

I spent a good chunk of time this weekend trying to get my blog automatically deploying on github pages via travis.



I already had a [reproducible nix-based build set up](http://huang-hobbs.co/blog/posts/2016-03-02-packaging-this-blog/) from a few years ago, so I decided to use that as my starting point. It was great because I could drop straight back into my development environment with maybe 5 minutes of work to get back to building the blog. 



The new derivation looks like this:

```Nix
let pkgs = import <nixpkgs> {};
in with pkgs;

let buildHaskell = haskellPackages.ghcWithPackages
      (hsPackages: with hsPackages; [
          # libraries
          hakyll
          hakyll-sass
      ]);

    buildLocale = "en_US.UTF-8";
    github_token = builtins.getEnv "GITHUB_PUBLISH_TOKEN";
    github_remote = "github.com/Adjective-Object/blog.git";

    version = builtins.fromJSON (
      builtins.readFile ./fixed-version.json
    );

in stdenv.mkDerivation {
  name = "blog";
  buildInputs = [ buildHaskell git glibcLocales time ];
  src = fetchgit {
    url = version.url;
    rev = version.rev;
    sha256 = version.sha256;
  };
    
  meta = {
    description = "Adjective-Object's blog site";
  };

  # disable other phases (too much stuff)
  phases = [ "unpackPhase" "configurePhase" "buildPhase" "installPhase"];

  # force UTF8 lang so hakyll won't panic when building
  configurePhase = ''
    export LOCALE_ARCHIVE=${glibcLocales}/lib/locale/locale-archive
    export GH_TOKEN=${github_token}
    export LANG=${buildLocale}
  '';

  buildPhase = "make";

  # hacky solution to deploy the result to gh_pages
  installPhase = ''
    mkdir $out
    mv _site/* $out
  '';
}
```



The biggest changes were

1. The fixed version of the build was moved into a separate standalone file, produced by `nix-prefetch-git`


1. The build is no longer effectful! Previously the derivation itself was responsible for publishing the built site to the `gh-pages` branch of the repo. The responsibility for deploying has been moved into a bash script run by travis.




Overall I'm satisfied with the new design, but as usual, using nix comes with a host of catches you don't normally bump into in most CI envirnments.



1. nix & the utilities included by nixpkgs are optimized for declaring derivations separately from source. I'm still actually building the derivation against a tarball fetched from github, it just _happens_ to be in the same directory as the source. 


1. Since nix is optimized for 100% reproducible builds, building against the current source tree feels like it's going against the grain of the package.

In order to hack around it, I'm storing the parameters to fetchFromGithub in a json file that I'm re-generating on every CI build.


1. Nix makes everything immutable in store (great), but I lost a good 10 minutes trying to debug why I didn't have permission to my temp directory when really I forgot to chmod directory I copied out of the store (the `nix-build` result)




Something that doesn't seem to have changed in the past 3 years is that the nix ecosystem isn't easily googleable, and a lot of the documentation isn't the best. I'm assuming that 



