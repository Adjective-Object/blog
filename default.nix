let pkgs = import <nixpkgs> {};
in with pkgs; let

    # build tools
    prohjectHaskellEnv =
        haskellPackages.ghcWithPackages 
            (hsPackages: with hsPackages; [
                hakyll
                hakyll-sass
            ]);

    dependencies = [
        stdenv
        prohjectHaskellEnv
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

