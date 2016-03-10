{ stdenv, pkgs, fetchFromGitHub }:
with pkgs;
let buildHaskell = haskellPackages.ghcWithPackages
      (hsPackages: with hsPackages; [
          # libraries
          hakyll
          hakyll-sass
      ]);

    buildLocale = "en_US.UTF-8";
    github_token = builtins.readFile ./github_token;
    github_remote = "github.com/Adjective-Object/blog.git";

in stdenv.mkDerivation {
  name = "blog";
  buildInputs = [ buildHaskell git glibcLocales time ];
  src = fetchFromGitHub {
    owner = "Adjective-Object";
    repo = "blog";
    rev = "2dcd6f70d2a9184bddf108f9520d480776e17a3c";
    sha256 = "09lkkwgxx21394pix80cqv8f45kvjswk2qz4w8785cg8bfhlk0pj";
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
    cd $out

    git init
    git config user.email "nix-autobuild@huang-hobbs.co"
    git config user.name "nix-autobuild"
    git config http.sslVerify false
    git add * > /dev/null
    git commit -am "Nix-build at `date`"

    echo "pushing to github..."
    git push --force --quiet \
      https://${github_token}@${github_remote} master:gh-pages > /dev/null

  '';

}

