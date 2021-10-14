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
        servant-reflex = doJailbreak (markUnbroken (super.servant-reflex));
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
  inherit project frontend backend;

  backend-runner = pkgs.writeShellScriptBin "backend-example" ''
    ${backend}/bin/backend ${frontend}/bin/frontend.jsexe
  '';
}
