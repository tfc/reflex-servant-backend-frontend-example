# Haskell Reflex + Servant Example

This repository contains a minimal running example of a reflex frontend to a
servant HTTP service. Both communicate via the servant API in `common`.

## Run the example

In order to run the app, you can build and execute `nix/backend-runner.nix`.
Then, open `http://localhost:3000`.

```bash
$(nix-build nix/backend-runner.nix)/bin/backend-example
```
