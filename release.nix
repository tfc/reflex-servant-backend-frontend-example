let
  sources = import ./nix/sources.nix { };
  haskellNix = import sources.haskellNix { };
  pkgs = import haskellNix.sources.nixpkgs haskellNix.nixpkgsArgs;

  hnixProject = pkgs.haskell-nix.cabalProject {
    src = pkgs.haskell-nix.haskellLib.cleanGit {
      name = "reflex-servant-backend-frontend-example";
      src = ./.;
    };
    compiler-nix-name = "ghc8107";
  };

  shellSettings = {
    tools = {
      cabal = "latest";
      ghcid = "latest";
      cabal-fmt = "latest";
    };
    withHoogle = false;
    exactDeps = true;
  };
in
rec {
  inherit hnixProject;
  frontend = hnixProject.projectCross.ghcjs.hsPkgs.frontend.components.exes.frontend;
  backend = hnixProject.backend.components.exes.backend;

  backend-runner = pkgs.writeShellScriptBin "backend-example" ''
    ${backend}/bin/backend ${frontend}/bin/frontend.jsexe
  '';

  shells = pkgs.recurseIntoAttrs {
    ghc = hnixProject.shellFor (shellSettings // {
      packages = ps: with ps; [
        frontend
        backend
        common
      ];
    });

    ghcjs = hnixProject.shellFor (shellSettings // {
      packages = ps: with ps; [
        frontend
        common
      ];
      crossPlatforms = ps: with ps; [ ghcjs ];
    });
  };
}
