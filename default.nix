let pkgs = import <nixpkgs> {};
in with pkgs; let

    # build tools
    projectHaskellEnv =
        haskellPackages.ghcWithPackages 
            (hsPackages: with hsPackages; [
                # libraries
                hakyll
                hakyll-sass

                # cabal
                cabal-install
            ]);

    dependencies = [
        stdenv
        projectHaskellEnv
    ];

in {
    devEnv = stdenv.mkDerivation {
        name = "hakyll-blog";
        buildInputs = dependencies;
        shellHook = ''
          export PATH="$PATH:./node_modules/.bin"
        '';
    };
}

