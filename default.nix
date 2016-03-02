{ stdenv, pkgs, fetchFromGitHub }:
with pkgs;
let buildHaskell = haskellPackages.ghcWithPackages
      (hsPackages: with hsPackages; [
          # libraries
          hakyll
          hakyll-sass

          # cabal
          cabal-install
      ]);

    buildLocale = "en_US.UTF-8";

in stdenv.mkDerivation {
  name = "blog";
  buildInputs = [ buildHaskell git glibcLocales ];
  src = fetchFromGitHub {
    owner = "Adjective-Object";
    repo = "blog";
    rev = "82f03fbd301cac06b20fefc700da684b289d8621";
    sha256 = "19blb75sr70bzb25k10d4fa490rqgbmnk889ga04xgm4csmihx27";
  };
  meta = {
    description = "Adjective-Object's blog site";
  };

  # disable other phases (too much stuff)
  phases = [ "unpackPhase" "configurePhase" "buildPhase" "installPhase"];

  # force UTF8 lang so hakyll won't panic when building
  configurePhase = ''
    export LOCALE_ARCHIVE=${glibcLocales}/lib/locale/locale-archive
    export LANG=${buildLocale}
  '';

  buildPhase = "make";

  # hacky solution to deploy the result to gh_pages
  installPhase = ''
    mkdir $out
    mv _site/* $out
    ./deploy_from.sh $out
  '';

}

