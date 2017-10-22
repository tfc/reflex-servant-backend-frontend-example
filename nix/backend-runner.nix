let
  sources = import ./nix/sources.nix;
  pkgs = (import sources.reflex-platform {}).nixpkgs;
  reflexProject = import ./nix/reflex.nix;
  inherit (reflexProject.ghcjs) frontend;
  inherit (reflexProject.ghc)   backend;
in
  pkgs.writeShellScriptBin "backend-example" ''
    ${backend}/bin/backend ${frontend}/bin/frontend.jsexe
  ''
