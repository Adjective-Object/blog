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

in stdenv.mkDerivation {
  name = "blog";
  buildInputs = [ buildHaskell git glibcLocales time ];
  src = pkgs.fetchFromGitHub (
    builtins.fromJSON (
      builtins.readFile ./fixed-version.json
    ));
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

