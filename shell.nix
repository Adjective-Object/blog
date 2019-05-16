let pkgs = import <nixpkgs> {};
    hieSrc = builtins.fetchTarball {
        url = https://github.com/domenkozar/hie-nix/tarball/hie-0.8.0.0;
        sha256 = "00v6k4kz62jhr6jzn2snh9s4ridiafz57da5czb3m5i4xpsqbmsw";
    };
    hie = import hieSrc {};
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
                hie.hie86
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

