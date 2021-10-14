let
  sources = import ./nix/sources.nix;
  reflex-platform = import sources.reflex-platform { };
  pkgs = reflex-platform.nixpkgs;
  project = reflex-platform.project ({ pkgs, ... }: {
    withHoogle = false;

    overrides = self: super:
      let
        inherit (pkgs.haskell.lib) markUnbroken doJailbreak dontCheck;
      in
      {
        servant-reflex =
          let
            src = pkgs.fetchFromGitHub
              {
                owner = "imalsogreg";
                repo = "servant-reflex";
                rev = "20e2621cc2eca5fe38f8a01c7a159b0b9be524ea";
                sha256 = "jyyTKPLKFeqq/R/F7kQ0cv/Fn8nQIKkAkT2N5wmYHis=";
              };
          in
          self.callCabal2nix "servant-reflex" src { };
        servant-server = dontCheck super.servant-server;
      };

    packages = {
      common = ./common;
      backend = ./backend;
      frontend = ./frontend;
    };

    shells = {
      ghc = [ "common" "backend" "frontend" ];
      ghcjs = [ "common" "frontend" ];
    };
  });

  inherit (project.ghcjs) frontend;
  inherit (project.ghc) backend;
in
{
  inherit frontend backend;

  backend-runner = pkgs.writeShellScriptBin "backend-example" ''
    ${backend}/bin/backend ${frontend}/bin/frontend.jsexe
  '';
}
