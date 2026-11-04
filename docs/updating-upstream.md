# Updating to a new Omarchy release

OmniXY consumes Omarchy as a pinned, non-flake input. To move to a new tag:

1. Bump the tag in `flake.nix` (`omarchy.url = "github:basecamp/omarchy/vX.Y.Z"`) and
   run `nix flake lock --update-input omarchy`.
2. Build the package: `nix build .#omarchy`. Failures here are almost always a path
   rewrite in `packages/omarchy/default.nix` that no longer matches, or a script in
   `archOnly` that upstream renamed or removed (missing names are skipped, so this
   only matters for new Arch-only commands).
3. Look over what changed upstream:
   ```bash
   git -C <omarchy checkout> diff vOLD..vNEW --stat -- bin install default config
   ```
   - **New commands that call pacman/yay/limine/snapper:** add them to `archOnly`, or
     write a NixOS version in `packages/omarchy/bin/`.
   - **`install/omarchy-base.packages` changes:** mirror them in `modules/packages.nix`.
   - **`install/config/*` or `enable-services.sh` changes:** mirror them in
     `modules/services.nix` / `modules/system.nix`.
   - **New `default/systemd/user` units:** enable them in `modules/user.nix`.
   - **Upstream migrations** are marked as applied (see below), so check any new
     ones in `migrations/` for user-config changes worth porting into the module.
4. Run the VM test: `nix build .#checks.x86_64-linux.desktop -L` and look at the
   screenshots in `result/`.

## Why migrations are skipped

Upstream migrations repair Arch installs from older Omarchy releases. Most of them
call pacman or edit `/etc`. On OmniXY the system side is declarative, so the skel
tree marks every shipped migration as applied, and `omnixy-seed-user` copies those
markers into `~/.local/state/omarchy/migrations` at each login.
