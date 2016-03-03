let pkgs = import <nixpkgs> {};
in with pkgs; let
    # build tools
    projectHaskellEnv =
        haskellPackages.ghcWithPackages 
            (hsPackages: with hsPackages; [
                # libraries
                hakyll
                hakyll-sass
                split

                # cabal
                cabal-install
            ]);

    dependencies = [
        stdenv
        projectHaskellEnv
    ];

in stdenv.mkDerivation {
    name = "hakyll-blog";
    buildInputs = dependencies;
}

