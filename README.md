# Debugging branch: Works with reflex-platform, not with haskell.nix

Build with reflex/haskell.nix:

```sh
nix-build reflex.nix -A backend-runner
nix-build haskellNix.nix -A backend-runner
```

Run and open in the browser:

```sh
./result/bin/backend-runner
xdg-open http://localhost:3000
```

Differences:

- In the reflex version you see XHR calls in the browser console.
- In the haskell.nix version you don't even see XHR calls, so it seems they
  are not sent.

# Haskell Reflex + Servant Example

This repository contains a minimal running example of a reflex frontend to a
servant HTTP service. Both communicate via the servant API in `common`.

## Run the example

In order to run the app, you can build and execute `nix/backend-runner.nix`.
Then, open `http://localhost:3000`.

```bash
$(nix-build nix/backend-runner.nix)/bin/backend-example
```
