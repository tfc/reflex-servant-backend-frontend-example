let
  sources = import ./sources.nix;
  reflex-platform = import sources.reflex-platform { };
in
reflex-platform.project ({ pkgs, ... }: {
  withHoogle = false;

  overrides = self: super: {
    servant-reflex = self.callPackage ./servant-reflex.nix { };
  };

  packages = {
    common = ../common;
    backend = ../backend;
    frontend = ../frontend;
  };

  android.frontend = {
    executableName = "frontend";
    applicationId = "org.example.frontend";
    displayName = "Example Android App";
  };

  ios.frontend = {
    executableName = "frontend";
    bundleIdentifier = "org.example.frontend";
    bundleName = "Example iOS App";
  };

  shells = {
    # The frontend is in the GHC shell to play with it in the REPL.
    # There is no ghcjs repl.
    ghc = [ "common" "backend" "frontend" ];
    ghcjs = [ "common" "frontend" ];
  };
})
