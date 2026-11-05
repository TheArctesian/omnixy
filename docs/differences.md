# How OmniXY differs from Omarchy on Arch

OmniXY runs upstream Omarchy's own code: its commands, Quickshell desktop, Hyprland
Lua config, themes and menus. What changes is everything Omarchy does to *the
system*, because NixOS owns `/etc`, `/usr` and package management.

## Replaced

| Upstream | OmniXY |
| --- | --- |
| `omarchy-settings` package, `install/config/*`, `install/hardware/*`, `install/login/*` | the NixOS module (`modules/`) |
| `/etc/skel` seeding | `omnixy-seed-user` runs at every session start and copies only missing files |
| `omarchy-update` (pacman, AUR, keyring, orphan cleanup) | `nix flake update` + `nixos-rebuild switch` on `omnixy.flake.path`, `nix profile upgrade`, mise, restart prompts |
| `omarchy-pkg-add/drop/present/missing` | nixpkgs via `nix profile`, with an Arch→nixpkgs name map (`omnixy-pkg resolve <name>` shows the mapping) |
| Install › Package / Remove › Package | nixpkgs search → `nix profile add`; profile list → `nix profile remove` |
| Snapper + limine snapshots | NixOS generations in the boot menu |
| `omarchy-apply-lock` (writes `/etc/pam.d/omarchy-lock-*`) | `security.pam.services.omarchy-lock-*` |
| Fingerprint / FIDO2 setup | print the NixOS options (`services.fprintd.enable`, `security.pam.u2f`) |
| ufw + ufw-docker | `networking.firewall` (LocalSend ports open) |
| `/usr/share/omarchy` | `/run/current-system/sw/share/omarchy` |
| `etc/` drop-ins (sysctl, logind, oomd, resolved, sudoers.d, docker) | `modules/tuning.nix` |
| `/usr/bin/<app>` checks | `command -v <app>` (finds nix profile installs too) |
| Store files copied read-only | `omnixy-cp` keeps copies writable |

## Apps that need a NixOS option

`omarchy-pkg-add` can't install these into a user profile. It prints the option to add
to your configuration instead: 1Password, Steam, Tailscale, Docker, Flatpak, fprintd,
FIDO2/U2F, OpenSSH server, Sunshine, supergfxctl, xpadneo, ydotool.

## Not available (Arch-only)

These commands are stubs that exit with an explanation: `omarchy-upgrade-to-quattro`,
`omarchy-refresh-pacman`, `omarchy-update-keyring`,
`omarchy-update-aur-pkgs`, `omarchy-update-pacman-guard`, `omarchy-update-pkg-prune`,
`omarchy-update-orphan-pkgs`, `omarchy-update-system-pkgs-when-conflicted`, `omarchy-pkg-aur-*`,
`omarchy-reinstall-pkgs`, `omarchy-channel-set`, `omarchy-dev-link/unlink`,
`omarchy-dev-pkg-test`, `omarchy-apply-system`, `omarchy-apply-hardware`,
`omarchy-provision-owner`, `omarchy-hibernation-setup/remove`,
`omarchy-toggle-hybrid-gpu`, `omarchy-snapshot`, `omarchy-system-factory-reset`.

The matching menu entries (Install › AUR, Update › Channel, Update › Config ›
Plymouth, Style › Unlock, Setup › Reset Computer, Hybrid GPU, Hibernate) are
removed. `omarchy-refresh-limine`, `omarchy-refresh-plymouth` and
`omarchy-refresh-sddm` succeed without doing anything, because the boot loader,
splash and login theme are declared in NixOS. AUR installs (Chrome, Edge, Brave)
go through the nixpkgs mapping.

## Not packaged for NixOS yet

- **Omarchy's own apps:** omacalc, omacut, omawrite, aether (theme designer). Their
  bindings and menu entries do nothing.
- **omarchy-nvim:** the Omarchy LazyVim setup ships as a separate Arch package. On
  OmniXY, `nvim` starts unconfigured. Install LazyVim yourself, or use the Neovim
  theme files Omarchy writes to `~/.local/state/omarchy/current/theme/neovim.lua`.
- **Hardware quirks** from `install/hardware/` (Apple T2, Surface, ASUS ROG,
  Framework 16, Dell XPS, Broadcom Wi-Fi, NVIDIA). Use
  [nixos-hardware](https://github.com/NixOS/nixos-hardware) and the usual
  `hardware.nvidia.*` options instead.
- **Offline ISO installer / provisioning flow:** the OmniXY ISO is a live desktop
  with the standard NixOS installer tools (`nixos-install`, `disko`), not Omarchy's
  guided installer.

## Known gaps

See [spec/gaps.md](spec/gaps.md) for the full list from the spec comparison.

## Migrations

Upstream migrations repair older Arch installs, so OmniXY marks them all as applied
(see [updating-upstream.md](updating-upstream.md)).
