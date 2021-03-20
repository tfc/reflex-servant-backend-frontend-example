let
  sources = import ./sources.nix;
  pkgs = (import sources.reflex-platform {}).nixpkgs;
  reflexProject = import ./reflex.nix;
  inherit (reflexProject.ghcjs) frontend;
  inherit (reflexProject.ghc)   backend;
in
  pkgs.writeShellScriptBin "backend-example" ''
    ${backend}/bin/backend ${frontend}/bin/frontend.jsexe
  ''
