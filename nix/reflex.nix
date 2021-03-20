let
  sources = import ./sources.nix;
  reflex-platform = import sources.reflex-platform { };
in
reflex-platform.project ({ pkgs, ... }: {
  withHoogle = false;

  overrides = self: super: let
    inherit (builtins) attrNames head readDir;
    extLibs = ./external-libs;
    libNames = attrNames (readDir extLibs);
    toCallPackage = nixFile: let
      name = head (pkgs.lib.splitString ".nix" nixFile);
      path = extLibs + "/${nixFile}";
    in
      { ${name} = self.callPackage path {}; };
  in builtins.foldl' (l: r: l // toCallPackage r) {} libNames;

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
