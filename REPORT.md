# Rewrite report: OmniXY on Omarchy v4.0.6

This rewrite was done overnight on branch `rewrite-v4`. The old tree was replaced. It was a hand-written re-implementation of Omarchy 2.x/3.x-era configs in Nix (Waybar, Walker, Mako, hyprland.conf and so on). The new design packages **upstream Omarchy itself** and replaces only the parts that assume Arch. The notes below cover what works, what was dropped and what is still open.

## Targets

| | |
| --- | --- |
| Omarchy | **v4.0.6** (latest stable tag, `237f1b4`). v4.5.0-rc3 exists but is a release candidate. |
| nixpkgs | nixos-unstable `0bb2eed` (Hyprland 0.57.0, Quickshell 0.3.2, uwsm 0.27.1) |
| Defaults chosen | from scratch · stable tag · runtime theme switching · placeholder user `omnixy` (`omnixy.user`) |

## Verified

- `nix flake check` passes: every host and the template evaluate, the example system builds, and the desktop VM test passes.
- **ISO builds.** `nix build .#iso` produces `omnixy-4.0.6-omnixy.iso` (4.5 GB live desktop with the NixOS installer tools and disko).
- **Desktop VM test** (`tests/desktop.nix`, `nix build .#checks.x86_64-linux.desktop -L`) checks each step and saves a screenshot:
  1. Boots and auto-logs in through SDDM into the `omnixy` session, then uwsm starts Hyprland.
  2. `omnixy-seed-user` seeds `~/.config`, `.bashrc` and the state dir, and sets the first theme (Tokyo Night).
  3. The Quickshell desktop (`omarchy-shell`) runs: bar, workspaces, clock, tray.
  4. <kbd>Super</kbd>+<kbd>Return</kbd> opens the terminal.
  5. <kbd>Super</kbd>+<kbd>Space</kbd> opens the Omarchy menu.
  6. `omarchy-theme-set Catppuccin` switches theme at runtime (wallpaper, bar, borders), with no rebuild.
  7. `omarchy-version` prints `4.0.6 (OmniXY)` and `omarchy commands` lists the CLI.
  Screenshots (from the VM test, software-rendered): [desktop](docs/screenshots/01-desktop.jpg),
  [terminal](docs/screenshots/02-terminal.jpg), [menu](docs/screenshots/03-menu.jpg),
  [Catppuccin](docs/screenshots/04-theme-catppuccin.jpg).
- All of OmniXY's replacement scripts pass `shellcheck -S warning`.

## Ported (how each upstream piece maps)

| Upstream (Arch) | OmniXY |
| --- | --- |
| `omarchy` package (bin, shell, themes, default/, config/) | `pkgs.omarchy`, at `/run/current-system/sw/share/omarchy`, with shebangs and paths patched |
| `omarchy-settings` (skel, /etc drop-ins, fonts, sddm, plymouth) | `modules/` + `omnixy-fonts`, `omnixy-sddm-theme`, `omnixy-plymouth-theme` |
| `/etc/skel` | `omnixy-seed-user` at each session start (copies only missing files, never overwrites) |
| `install/omarchy-base.packages` | `modules/packages.nix` (plus `omnixy.preinstalls` for the optional apps) |
| `install/config/*`, `enable-services.sh` | `modules/services.nix`, `modules/system.nix` |
| `omarchy-pkg-*`, Install › Package | `omnixy-pkg`: Arch→nixpkgs name map, `nix profile add`. Service-backed apps print the NixOS option to set. |
| `omarchy-update` | `nix flake update` + `nixos-rebuild switch` on `omnixy.flake.path`, profile upgrade, mise, restart prompts |
| Lock-screen PAM (`omarchy-apply-lock`) | `security.pam.services.omarchy-lock-{password,fingerprint}` |
| User systemd units | shipped in the package and enabled in `modules/user.nix` |
| ttfx, tensaku (not in nixpkgs) | packaged in `packages/` |

## Dropped / not available

- **Arch-only commands** (25, listed in `packages/omarchy/default.nix` `archOnly` and in `docs/differences.md`): pacman/AUR/keyring, limine/snapper snapshots, channel switching, firmware updater wrapper, hibernation setup, hybrid-GPU toggle, factory reset, the v3→v4 "Quattro" upgrade. They are now stubs that exit with an explanation. Their menu entries were removed.
- **Upstream migrations**: they repair older Arch installs, so new users start with all of them marked as applied.
- **The old OmniXY tree**: the Waybar/Walker/Mako modules, the hand-written scripts and the old wallpapers. Omarchy v4 replaced those components itself, with the Quickshell shell, Lua Hyprland config and bundled themes.

## Still open

1. **Omarchy's own apps are not packaged:** omacalc, omacut, omawrite, aether, and the omarchy-nvim LazyVim config. Their bindings do nothing.
2. **Hardware quirks** from `install/hardware/` (T2 Macs, Surface, ASUS, Framework, NVIDIA): use nixos-hardware instead. They are not mirrored.
3. **The ISO is a live desktop and has no guided installer.** You install with `nixos-install`/disko and the template. An Omarchy-style guided installer would be a separate project.
4. **Not tested on real hardware.** The VM test uses software rendering. Real-GPU checks are still needed for Plymouth, SDDM theme rendering, suspend/lock and fingerprint.
5. **The `omnixy-pkg` name map is curated, not exhaustive.** Unknown Arch names fall through to the same nixpkgs attribute name. Check with `omnixy-pkg resolve <name>`.
6. **Harmless log noise:** the shell warns about `Unrecognized pragma OmarchyLoadPatch` (Quickshell 0.3.2 vs upstream's patched build), and about missing Bluetooth in the VM. In the slow VM, a background-transition snapshot is deleted before QML loads it (upstream removes it after 3 s).
7. **Host note: KVM is not reachable inside the nix build sandbox on this machine.** You get "Could not access KVM kernel module: Permission denied", so VM tests fall back to TCG and take about 5 to 10 minutes. To fix it, give the build users access to `/dev/kvm`, for example by adding `kvm` to `system-features` in `/etc/nix/nix.conf` and making sure `/dev/kvm` is group `kvm` with mode 0660, and the nixbld users are in that group.

## Try it

```bash
nix run .#vm                                   # throwaway VM (omnixy/omnixy)
nix build .#iso                                # live ISO
nix build .#checks.x86_64-linux.desktop -L     # VM test + screenshots in result/
```
