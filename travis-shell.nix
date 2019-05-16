let pkgs = import <nixpkgs> {};
in with pkgs; let
    # build tools
    projectHaskellEnv =
        haskellPackages.ghcWithPackages 
            (hsPackages: with hsPackages; [
                # libraries
                hakyll
                hakyll-sass
                regex-compat
                split
            ]);

    dependencies = [
        stdenv
        projectHaskellEnv
        nix-prefetch-git
    ];

in stdenv.mkDerivation {
    name = "hakyll-blog";
    buildInputs = dependencies;
}

