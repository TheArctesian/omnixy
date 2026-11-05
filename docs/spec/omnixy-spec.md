# OmniXY project specification

- Subject: OmniXY, branch `rewrite-v4`, as it exists on 2026-11-04.
- Re-audit: 2026-11-04, after PRs #3 (`spec-gaps`) and #4 (`oma-apps`), on branch `small-fixes`. The statuses in this document describe that tree. The re-audit tree includes the staged `omnixy-pkg list` change.
- Reference: Omarchy `v4.0.6` (flake input `omarchy`).
- Language: ASD-STE100 Simplified Technical English.
- Method: source read, `nix eval` of `nixosConfigurations.example`, `nix build` of `pkgs.omarchy` and the system path, static dependency scan of all scripts, and one scratch-HOME reproduction of the theme switch. No VM test and no ISO build were run for the first audit. The re-audit adds a read of the PR #3 and PR #4 diffs, a new `nix build` of `pkgs.omarchy`, `nix eval` of the example host and a passing VM test (`tests/desktop.nix`). The system path in section 2 is from the first audit.

## Status summary

| Status | First audit | Re-audit (after PRs #3 and #4) |
|---|---|---|
| `WORKS` | 163 | 236 |
| `PARTIAL` | 34 | 28 |
| `STUB` | 22 | 22 |
| `BROKEN` | 99 | 24 |
| `NOT VERIFIED` | 59 | 69 |
| Total | 377 | 379 |

The re-audit adds ONX-13-013 and ONX-13-014. Re-audit count for each section (`WORKS`/`PARTIAL`/`STUB`/`BROKEN`/`NOT VERIFIED`):

| Section | WORKS | PARTIAL | STUB | BROKEN | NOT VERIFIED |
|---|---|---|---|---|---|
| 1 | 2 | 1 | 0 | 0 | 0 |
| 3 | 14 | 1 | 0 | 0 | 0 |
| 4 | 16 | 0 | 0 | 3 | 10 |
| 5 | 16 | 0 | 0 | 1 | 1 |
| 6 | 31 | 1 | 0 | 0 | 1 |
| 7 | 14 | 1 | 0 | 0 | 0 |
| 8 | 5 | 2 | 0 | 0 | 7 |
| 9 | 36 | 1 | 0 | 1 | 5 |
| 10 | 6 | 2 | 0 | 2 | 2 |
| 11 | 66 | 12 | 19 | 14 | 30 |
| 12 | 8 | 1 | 0 | 0 | 1 |
| 13 | 4 | 1 | 0 | 0 | 9 |
| 14 | 5 | 2 | 2 | 2 | 1 |
| 15 | 10 | 1 | 0 | 1 | 1 |
| 16 | 3 | 2 | 1 | 0 | 1 |

## 1. Scope

This document specifies OmniXY as it is. It does not specify intentions. Text in `README.md`, `REPORT.md` and `docs/differences.md` is a claim, not evidence. This document has the same outline as the Omarchy specification. Use the two documents together to compare each requirement.

Each requirement has these fields:

| Field | Content |
|---|---|
| ID | `ONX-<section>-<nnn>` |
| Requirement | One STE statement. |
| Status | `WORKS`, `PARTIAL`, `STUB`, `BROKEN` or `NOT VERIFIED`. |
| Evidence | The file, the eval result, the build output or the test that supports the status. |

| ID | Requirement | Status | Evidence |
|---|---|---|---|
| ONX-1-001 | OmniXY must give the Omarchy v4.0.6 desktop on NixOS through one flake. | PARTIAL | `flake.nix`; sections 4 to 16 of this document list the gaps. |
| ONX-1-002 | OmniXY must support only the `x86_64-linux` system. | WORKS | `flake.nix` sets `system = "x86_64-linux"`. |
| ONX-1-003 | OmniXY must take the Omarchy source from the tag `v4.0.6` without a fork. | WORKS | `flake.nix` input `omarchy = github:basecamp/omarchy/v4.0.6`, `flake = false`. |

## 2. Definitions

| Term | Definition |
|---|---|
| Omarchy | The upstream Arch Linux desktop configuration, version `v4.0.6`. |
| OmniXY | The NixOS port in this repository. |
| upstream | The Omarchy source tree at tag `v4.0.6`. |
| omarchy package | The Nix derivation `pkgs.omarchy`, version `4.0.6-omnixy`. It holds the patched upstream tree. Build output at the re-audit: `/nix/store/d6mpb5yk1bd9z70f5bw1p9f20akxpqj0-omarchy-4.0.6-omnixy`. |
| OMARCHY_PATH | The directory `/run/current-system/sw/share/omarchy`. |
| skel tree | The directory `/run/current-system/sw/share/omnixy/skel`. It holds the default user files. |
| system path | The derivation `system-path` of the example host. Build output: `/nix/store/x005i70dhqgdajylxisdw8kxhzq3wiy7-system-path`. It has 1884 commands in `bin/`. |
| module | The NixOS module `nixosModules.omnixy` in `modules/`. |
| example host | The configuration `nixosConfigurations.example` in `hosts/example`. All eval results in this document come from this host. |
| command | An executable file in `OMARCHY_PATH/bin`. The omarchy package has 455 commands. |
| stub | A command that OmniXY replaces with a script that prints a message and exits with code 1. |
| replacement | A command that OmniXY replaces with a new NixOS script in `packages/omarchy/bin`. |
| menu entry | One item in the Omarchy menu file that the omarchy package installs. |
| shell | The Quickshell 0.3.2 program that runs `OMARCHY_PATH/shell`. It shows the bar, the menu, notifications, OSD, lock and panels. |
| package map | The table `MAP` in `omnixy-pkg`. It maps an Arch package name to a nixpkgs attribute. |
| map marker `!` | A package map value. The package needs a NixOS option. |
| map marker `-` | A package map value. OmniXY already provides the package. |
| map marker `?` | A package map value. No nixpkgs package exists for this name. |
| user profile | The Nix profile `~/.nix-profile`. `nix profile add` writes to it. |
| VM test | The check `checks.x86_64-linux.desktop` in `tests/desktop.nix`. |
| static scan | A read of the script text and a check that each called command exists in the system path. A static scan does not run the script. |
| read-only store | The Nix store. Files copied from it with `cp -r` keep the read-only mode. |

Status values:

| Status | Meaning |
|---|---|
| `WORKS` | The VM test passes it, or a build or eval shows the result, or the static scan finds all dependencies. |
| `PARTIAL` | The main function works, but one or more parts fail or are absent. |
| `STUB` | The command exists only as a stub. |
| `BROKEN` | The function fails. The evidence column gives the cause. |
| `NOT VERIFIED` | No evidence is available for or against the function. |

## 3. System overview and architecture

| ID | Requirement | Status | Evidence |
|---|---|---|---|
| ONX-3-001 | The flake must export `overlays.default`. | WORKS | `flake.nix`. |
| ONX-3-002 | The flake must export `nixosModules.default` and `nixosModules.omnixy`. | WORKS | `flake.nix`. |
| ONX-3-003 | The flake must export the configurations `example`, `vm` and `iso`. | WORKS | `flake.nix`; `nix eval` of `example` succeeds. |
| ONX-3-004 | The flake must export the packages `omarchy`, `omnixy-fonts`, `ttfx`, `tensaku`, `iso`, `vm` and `default`. | WORKS | `flake.nix`; it also exports `aether`, `omazed`, `omarchy-nvim`, `omacalc`, `omawrite` and `omacut`. `nix build .#omarchy` succeeds. |
| ONX-3-005 | The flake must export `apps.vm`, which runs `run-omnixy-vm-vm`. | WORKS | `flake.nix`. |
| ONX-3-006 | The flake must export `templates.default`, `formatter` (`nixfmt`) and a dev shell. | WORKS | `flake.nix`. |
| ONX-3-007 | The overlay must build `omarchy`, `omnixy-fonts`, `omnixy-sddm-theme`, `omnixy-plymouth-theme`, `ttfx` 0.5.1 and `tensaku` 0.29.0. | WORKS | `packages/overlay.nix`. It also builds `aether`, `omazed`, `omarchy-nvim`, `omacalc`, `omawrite` and `omacut`. |
| ONX-3-008 | The omarchy package must rewrite `/usr/share/omarchy`, `/usr/share/applications`, `,/usr}/share/` and `/etc/skel` to store paths at build time. | WORKS | `packages/omarchy/default.nix` sed. |
| ONX-3-009 | The omarchy package must rewrite each `/usr/bin/<name>` in the scripts to a `PATH` lookup. | WORKS | `packages/omarchy/default.nix` now rewrites all `/usr/bin/<name>`. `[[ -x /usr/bin/<name> ]]` becomes `command -v <name>`. A scan of the build output finds `/usr/bin` only in `PATH=` strings. See ONX-11-127. |
| ONX-3-010 | The omarchy package must install `share/omarchy`, `share/omnixy`, `share/systemd`, `share/wayland-sessions` and `share/xdg-terminal-exec`. | WORKS | Build output `$out/share`. |
| ONX-3-011 | The omarchy package must install the upstream icons into `share/icons/hicolor`. | WORKS | Build output has `share/icons/hicolor/256x256/apps` with 17 icons. The VM test finds `hey.png`. |
| ONX-3-012 | The module must set `OMARCHY_PATH` to `/run/current-system/sw/share/omarchy`. | WORKS | `modules/desktop.nix` sessionVariables. |
| ONX-3-013 | The desktop must run Hyprland 0.57.0 with the upstream Lua configuration. | WORKS | VM test starts the session; `default/hypr/*.lua`. |
| ONX-3-014 | The shell must run Quickshell 0.3.2 with `OMARCHY_PATH/shell`. | WORKS | VM test checks that `quickshell` runs. |
| ONX-3-015 | The shell must load `shell.qml` without warnings. | PARTIAL | `shell.qml` line 1 has `//@ pragma OmarchyLoadPatch`. Quickshell 0.3.2 does not know this pragma and logs a warning. `REPORT.md` lists the same item. |

## 4. Installation and provisioning

| ID | Requirement | Status | Evidence |
|---|---|---|---|
| ONX-4-001 | The user must enable OmniXY with `omnixy.enable = true` and `omnixy.user`. | WORKS | `modules/default.nix`. |
| ONX-4-002 | The module must give the options `fullName`, `email`, `theme`, `autoLogin`, `flake.path`, `flake.host` and `preinstalls.enable`. | WORKS | `modules/default.nix`. Defaults: theme "Tokyo Night", autoLogin false, flake.path "/etc/nixos", flake.host null, preinstalls true. |
| ONX-4-003 | The module must give the options `features.docker`, `printing`, `bluetooth`, `plymouth` and `firewall`. All defaults must be true. | WORKS | `modules/default.nix`. |
| ONX-4-004 | The template must give a flake with `nixosConfigurations.omnixy`. | WORKS | `templates/default/flake.nix`. |
| ONX-4-005 | The example host must evaluate and build. | WORKS | `checks.example` is the toplevel; `nix build` of the system path succeeds. |
| ONX-4-006 | The example host must set user `omnixy`, password "omnixy", host name `omnixy`, `Europe/London`, `en_GB`, keymap `uk`, xkb `gb`, systemd-boot and stateVersion 26.05. | WORKS | `hosts/example/default.nix`. |
| ONX-4-007 | The VM host must set autoLogin, no preinstalls, no plymouth, 8 GB RAM, 4 cores and `virtio-vga-gl`. | WORKS | `hosts/vm`. |
| ONX-4-008 | The ISO host must boot a graphical live session with autoLogin, `gparted` and `disko`. Its volume ID must be `OMNIXY`. | NOT VERIFIED | `hosts/iso`. No ISO build was run. |
| ONX-4-009 | The ISO must give a guided installer. | BROKEN | `hosts/iso` has no installer program. `REPORT.md` lists this item as open. |
| ONX-4-010 | The display manager must start the session `omnixy`. | WORKS | `modules/desktop.nix` defaultSession `omnixy`; VM test logs in through SDDM autologin. |
| ONX-4-011 | `omnixy-session` must source the uwsm env.d file, run `omnixy-seed-user` and then run `uwsm start -g -1 -e -D Hyprland hyprland.desktop`. | WORKS | `packages/omarchy/bin/omnixy-session`; VM test. |
| ONX-4-012 | `omnixy-seed-user` must copy the skel tree into HOME without overwriting existing files. | WORKS | `cp -rn --no-preserve=mode,ownership`; VM test checks `hyprland.lua`, `.bashrc` and `theme.name`. |
| ONX-4-013 | `omnixy-seed-user --force` must overwrite the user files with the skel tree. | NOT VERIFIED | `cp -rf` path in the script; not run. |
| ONX-4-014 | `omnixy-seed-user` must apply the theme `OMNIXY_DEFAULT_THEME` once, without a display. | WORKS | VM test finds `theme.name`. |
| ONX-4-015 | The autostart must run `omarchy-launch-shell`, `omarchy-provision-first-run`, `omarchy-powerprofiles-init`, `omarchy-hyprland-monitor-watch`, `udiskie --automount` and `omarchy-hook post-boot`. | WORKS | `default/hypr/autostart.lua`; all commands exist in the system path. |
| ONX-4-016 | First run must enable the user units `bt-agent`, `omarchy-recover-internal-monitor`, `omarchy-sleep-lock`, `omarchy-migrate-notify`, `omarchy-fcitx5` and `omarchy-crash-watch`. | WORKS | `enable-user-units.sh` runs `systemctl --user enable --now`; the units come from `systemd.packages`. |
| ONX-4-017 | First run must set the GNOME theme with gsettings (`Adwaita-dark`, `prefer-dark`, `Yaru-blue`). | NOT VERIFIED | `glib` and the schemas path are present; not run. |
| ONX-4-018 | First run must run `omarchy-audio-tuning on`. | BROKEN | `pactl` is now present. The tuning stops because it checks `/usr/lib/lv2/lsp-plugins.lv2`, which does not exist on NixOS. See ONX-11-102. |
| ONX-4-019 | First run must wait for the network with `nm-online` and then show the update notification. | WORKS | `nm-online` is in the system path. |
| ONX-4-020 | First run must show the voxtype, fingerprint and agent invitations through hooks. | NOT VERIFIED | Hooks exist in the skel tree; not run. |
| ONX-4-021 | `omarchy-provision-user` must create the XDG user directories and GTK bookmarks. | NOT VERIFIED | `xdg-user-dirs` is present; not run. |
| ONX-4-022 | `omarchy-provision-user` must run `omarchy-refresh-applications`. | WORKS | The copies now go through `omnixy-cp`. See ONX-11-118. |
| ONX-4-023 | `omarchy-provision-user` must set Chromium as the default browser and HEY as the `mailto` handler. | NOT VERIFIED | `xdg-settings` and `/etc/xdg/mimeapps.list` exist; not run. |
| ONX-4-024 | `install/user/chromium.sh` must install the native messaging hosts. | NOT VERIFIED | Not run. |
| ONX-4-025 | `install/user/git.sh` must set the git identity from `OMARCHY_USER_NAME` and `OMARCHY_USER_EMAIL`. | WORKS | `modules/user.nix` sets both variables. |
| ONX-4-026 | `install/user/mise-work.sh` must create `~/Work`. Node must come from a tarball only in the ISO context. | NOT VERIFIED | Not run. |
| ONX-4-027 | `install/user/mise.sh` must install the agent CLIs (codex, claude, crush, gemini, gh, copilot, opencode, playwright, pi, omp, grok, cursor-agent, ghui, hunk, muse) through `omarchy-mise-install`. | NOT VERIFIED | `mise` is present. Prebuilt binaries need a dynamic loader; `programs.nix-ld` is false. See ONX-11-132. |
| ONX-4-028 | First run must write the finalize-user marker. | NOT VERIFIED | Not run. |
| ONX-4-029 | The hardware fix scripts in `install/user` (asus, framework, dell, nouveau) must run. | BROKEN | `pactl` is now present. asusctl is still absent. No NixOS module mirrors the quirks. See section 14. |

## 5. Packages

| ID | Requirement | Status | Evidence |
|---|---|---|---|
| ONX-5-001 | The module must install the core list of about 130 packages. | WORKS | `modules/packages.nix`; system path build. The core list now has `omarchy-nvim` and the runtime tools of ONX-5-008 to ONX-5-011. |
| ONX-5-002 | The core list must include `omarchy`, the fonts, `ttfx`, `tensaku`, `quickshell`, `uwsm`, the Hypr tools and `foot`. | WORKS | System path `bin/`. |
| ONX-5-003 | The core list must include `grim`, `slurp`, `wl-clipboard`, `brightnessctl`, `ddcutil`, `pamixer`, `playerctl`, `swayosd` and `gpu-screen-recorder`. | WORKS | System path `bin/`. |
| ONX-5-004 | The core list must include `nautilus`, `evince`, `imv`, `mpv`, `fcitx5`, `chromium`, `impala`, `iwgtk`, `wiremix` and `bluetui`. | WORKS | System path `bin/`. |
| ONX-5-005 | The core list must include `mise`, `lua5_1`, `ruby`, `clang`, `python3`, `glib`, `cliamp` and `tzupdate`. | WORKS | System path `bin/`. |
| ONX-5-006 | With `preinstalls.enable`, the module must install `libreoffice-fresh`, `obsidian`, `obs-studio`, `kdenlive`, `pinta`, `xournalpp`, `localsend`, `moonlight-qt` and `mpvScripts.mpris`. | WORKS | `modules/packages.nix`. The list now uses `libreoffice` and adds `aether`, `omacalc`, `omacut` and `omawrite`. Eval shows them in `environment.systemPackages`. |
| ONX-5-007 | The module must set `nixpkgs.config.allowUnfree`. | WORKS | `modules/packages.nix`. |
| ONX-5-008 | The system path must provide `pactl` (libpulse). | WORKS | `modules/packages.nix` links `pactl` from libpulse without the PulseAudio daemon. The VM test runs `pactl info`. |
| ONX-5-009 | The system path must provide the fcitx5 GTK and Qt input modules. | WORKS | `modules/system.nix` sets `i18n.inputMethod` to fcitx5 with `fcitx5-gtk`. Eval: the `fcitx5-with-addons` derivation has `fcitx5-qt5` and `fcitx5-qt6`. |
| ONX-5-010 | The system path must provide `gtk-launch` and `gtk-update-icon-cache`. | WORKS | `gtk3` and `hicolor-icon-theme` are in the core list (`modules/packages.nix`). |
| ONX-5-011 | The system path must provide `iw`, `v4l2-ctl`, `cryptsetup` and `efibootmgr`. | WORKS | `iw`, `v4l-utils`, `cryptsetup` and `efibootmgr` are in the core list (`modules/packages.nix`). |
| ONX-5-012 | The system path must provide `cups-pk-helper`. | WORKS | Eval: `cups-pk-helper-0.2.6` is in `environment.systemPackages`. |
| ONX-5-013 | The system path must provide the Tesseract English data for OCR. | NOT VERIFIED | Not checked in the tensaku closure. |
| ONX-5-014 | The system must provide `omarchy-nvim` (the LazyVim configuration). | WORKS | `packages/omarchy-nvim.nix` is in the core list. `omnixy-seed-user` runs `omarchy-nvim-setup` when `~/.config/nvim` is absent. The VM test checks the seeded files. |
| ONX-5-015 | The system must provide the Oma apps `omacalc`, `omacut`, `omawrite`, `aether` and `omazed`. | WORKS | `packages/aether.nix`, `oma-qt-app.nix` and `omazed.nix` build. Preinstalls add aether, omacalc, omacut and omawrite. `omnixy-pkg` installs omazed from `omnixy#omazed`. The VM test opens omacalc and omawrite. |
| ONX-5-016 | The system must provide `tobi-try` and `asdcontrol`. | BROKEN | Not packaged; comment in `modules/packages.nix`. `docs/spec/gaps.md` lists it as open. |
| ONX-5-017 | The module must drop the Arch-only packages `yay`, `expac`, `fakeroot`, `pacman-contrib`, `kernel-modules-hook`, `qemu-user-static-binfmt`, `ufw` and `ufw-docker`. | WORKS | `modules/packages.nix` comment. |
| ONX-5-018 | The `localsend` command must exist. | WORKS | With preinstalls, `modules/packages.nix` links `localsend` to `localsend_app`. |

## 6. System configuration

| ID | Requirement | Status | Evidence |
|---|---|---|---|
| ONX-6-001 | NetworkManager must run with the `iwd` Wi-Fi backend. | WORKS | `modules/services.nix`. |
| ONX-6-002 | `NetworkManager-wait-online` must be disabled. | WORKS | `modules/services.nix`. |
| ONX-6-003 | `systemd-resolved` must run. | WORKS | `modules/services.nix`. |
| ONX-6-004 | resolved must set `LLMNR=no`, `MulticastDNS=no` and `DNSStubListenerExtra=172.17.0.1`. | WORKS | `modules/tuning.nix` `services.resolved.settings.Resolve`. `DNSStubListenerExtra` is set only with `features.docker`. |
| ONX-6-005 | NetworkManager must set `wifi.powersave=2`. | WORKS | `modules/tuning.nix` `networking.networkmanager.settings`. |
| ONX-6-006 | PipeWire must run with ALSA, 32-bit ALSA, Pulse, JACK and WirePlumber. `rtkit` must be on. | WORKS | `modules/services.nix`. |
| ONX-6-007 | Bluetooth must be on and power on at boot. | WORKS | `modules/services.nix`. |
| ONX-6-008 | CUPS and `cups-browsed` must run. Avahi must run with `nssmdns4` and an open firewall. | WORKS | `modules/services.nix`. |
| ONX-6-009 | Docker must be installed and must not start at boot. | WORKS | `virtualisation.docker.enableOnBoot = false`. |
| ONX-6-010 | Docker must use the upstream `daemon.json` (log options, DNS, `bip`). | WORKS | `modules/tuning.nix` `virtualisation.docker.daemon.settings`. |
| ONX-6-011 | The user must be in the `docker` group. | WORKS | `modules/tuning.nix` adds `docker` with `features.docker`. The VM test checks `id -nG`. |
| ONX-6-012 | `power-profiles-daemon`, `upower`, `udisks2`, `gvfs`, `tumbler`, `bolt`, `fwupd` and `plocate` must run. | WORKS | `modules/services.nix`; eval. |
| ONX-6-013 | `plocate` must update only on AC power. | WORKS | `modules/tuning.nix` sets `ConditionACPower` on `update-locatedb`. |
| ONX-6-014 | `systemd-oomd` must run with user slices. | WORKS | `modules/services.nix`. |
| ONX-6-015 | oomd must use the upstream pressure limit 50% for 20 s. | WORKS | `modules/tuning.nix` `systemd.oomd.settings.OOM`. |
| ONX-6-016 | zram swap must use 100% of RAM, `zstd` and priority 100. | WORKS | `modules/services.nix`. |
| ONX-6-017 | zswap must be disabled. | WORKS | `modules/tuning.nix` adds `zswap.enabled=0` when zram is on. |
| ONX-6-018 | sysctl must set `vm.swappiness=150`, the other upstream vm values and `tcp_mtu_probing`. | WORKS | `modules/tuning.nix` sets the upstream vm values and `tcp_mtu_probing`. The VM test reads `vm.swappiness` 150. |
| ONX-6-019 | logind must set `HandlePowerKey=ignore` and `InhibitDelayMaxSec=15`. | WORKS | `modules/tuning.nix` `services.logind.settings.Login`. |
| ONX-6-020 | systemd must set `DefaultTimeoutStopSec=5s` and the upstream `NOFILE` limit. | WORKS | `modules/tuning.nix` `systemd.settings.Manager` and `systemd.user.settings.Manager`. |
| ONX-6-021 | `usbcore` autosuspend must be `-1`. | WORKS | `modules/tuning.nix` `boot.extraModprobeConfig`. |
| ONX-6-022 | The fonts must include `omnixy-fonts`, JetBrainsMono Nerd, Noto, Noto CJK Sans, Noto Color Emoji, Liberation, Font Awesome and iA Writer Duospace. | WORKS | `modules/system.nix`. |
| ONX-6-023 | fontconfig must use the upstream defaults and `50-omarchy.conf`. | WORKS | `modules/system.nix` localConf. |
| ONX-6-024 | Plymouth must use the theme `omarchy` with `quiet`, `splash` and `udev.log_level=3`. | NOT VERIFIED | `modules/system.nix`; eval shows `boot.plymouth.enable`. Not booted. |
| ONX-6-025 | `/etc/xdg/mimeapps.list`, `/etc/chromium/initial_preferences` and `environment.d/10-omarchy-fcitx.conf` must exist. | WORKS | `environment.etc` eval. |
| ONX-6-026 | Bash must source `OMARCHY_PATH/default/bash/rc` when `~/.bashrc` does not. | WORKS | `modules/system.nix` interactiveShellInit. |
| ONX-6-027 | Nix must enable `nix-command` and `flakes`. | WORKS | `modules/system.nix`. |
| ONX-6-028 | The Hyprland keyboard layout must follow the host keyboard layout. | WORKS | `modules/system.nix` writes `XKBLAYOUT`, `XKBVARIANT` and `XKBOPTIONS` from `services.xserver.xkb`. The VM test checks `XKBLAYOUT`. |
| ONX-6-029 | The time zone must be settable at run time. | WORKS | The example host and the template leave `time.timeZone` unset. Eval: null. A sudoers rule grants `timedatectl set-timezone`. Not run. |
| ONX-6-030 | `systemd-timesyncd` must run. | WORKS | Eval. |
| ONX-6-031 | The man cache must be off. | WORKS | `modules/system.nix`. |
| ONX-6-032 | `/etc/shells` must contain the bash path that the scripts compare against. | WORKS | `/etc/shells` contains the store bash path. |
| ONX-6-033 | The upstream `/etc` files for fastfetch, gnupg dirmngr, mise, `profile.d` and kitty must exist. | PARTIAL | `modules/tuning.nix` mirrors fastfetch, dirmngr, mise and kitty. `profile.d/omarchy.sh` (the `env-bootstrap` source) is not mirrored. |

## 7. User environment

| ID | Requirement | Status | Evidence |
|---|---|---|---|
| ONX-7-001 | The module must create the user with the groups wheel, networkmanager, video, audio, input, lp and scanner. | WORKS | `modules/user.nix`. `modules/tuning.nix` also adds `docker` (ONX-6-011). |
| ONX-7-002 | The session must set `OMARCHY_PATH`, `OMNIXY_FLAKE`, `OMNIXY_DEFAULT_THEME`, `TERMINAL=xdg-terminal-exec` and `NIXOS_OZONE_WL=1`. | WORKS | `modules/desktop.nix`. |
| ONX-7-003 | The session must set `OMNIXY_HOST` when `flake.host` is set. | WORKS | `modules/desktop.nix`. |
| ONX-7-004 | The session must set `OMARCHY_USER_NAME` and `OMARCHY_USER_EMAIL`. | WORKS | `modules/user.nix`. |
| ONX-7-005 | `xdg-terminal-exec` must open `foot`. | WORKS | `xdg.terminal-exec` uses `foot.desktop`; VM test opens foot. |
| ONX-7-006 | The skel tree must hold `.bashrc` and the configurations for alacritty, btop, chromium, fcitx5, foot, ghostty, git, herdr, hypr, imv, kitty, lazygit, obsidian, omarchy, opencode, starship, tmux, wireplumber and xournalpp. | WORKS | Build output `share/omnixy/skel`. |
| ONX-7-007 | The skel tree must hold 17 desktop files for web apps and tools. | WORKS | Build output `share/omnixy/skel/.local/share/applications`. |
| ONX-7-008 | The desktop file icons must show. | WORKS | ONX-3-011. `foot` and `mpv` get their icons from their packages. |
| ONX-7-009 | The skel tree must hold 120 migration markers so that `omarchy-migrate` skips old migrations. | WORKS | Build output. |
| ONX-7-010 | The skel tree must hold the nautilus-python extensions. | WORKS | Build output. |
| ONX-7-011 | The module must enable the user units `omarchy-sleep-lock`, `omarchy-fcitx5`, `omarchy-crash-watch` and `omarchy-recover-internal-monitor`. | WORKS | `modules/user.nix` wantedBy `graphical-session-pre.target`. |
| ONX-7-012 | The module must enable `bt-agent` when Bluetooth is on. | WORKS | `modules/user.nix`. |
| ONX-7-013 | The module must enable `omarchy-migrate-notify`, `omarchy-speaker-tuning` and `omarchy-tailscale-receive`. | PARTIAL | The module does not enable them. First run enables only `omarchy-migrate-notify`. |
| ONX-7-014 | The user app slice must have the upstream OOM kill settings. | WORKS | `modules/user.nix`. |
| ONX-7-015 | fcitx5 input must work in GTK and Qt programs. | WORKS | ONX-5-009. |

## 8. Desktop shell

| ID | Requirement | Status | Evidence |
|---|---|---|---|
| ONX-8-001 | `omarchy-launch-shell` must start Quickshell with `-n -p $OMARCHY_PATH/shell` through `systemd-cat`. | WORKS | VM test checks that `quickshell` runs. |
| ONX-8-002 | The bar must show at the top with the upstream left, center and right widgets. | NOT VERIFIED | `config/omarchy/shell.json`; VM test takes no bar assertion. |
| ONX-8-003 | SUPER+SPACE must open the menu. | WORKS | VM test sends `meta_l-spc` and takes a screenshot. The test does not assert the content. |
| ONX-8-004 | The menu must hide the entries `install.aur`, `update.channel*`, `setup.reset`, `style.unlock`, `update.config.plymouth`, `trigger.hardware.hybrid-gpu` and `system.hibernate`. | WORKS | `packages/omarchy/default.nix` sed; entry count 333 to 322. `update.firmware` is back (ONX-13-009). |
| ONX-8-005 | The menu must label the package entry "Package (nixpkgs)". | WORKS | `packages/omarchy/default.nix` sed. |
| ONX-8-006 | The shell must load the plugins agents, background, bar, clipboard, dev-gallery, emojis, image-picker, lock, menu, notifications, osd, panels, polkit, reminders and services. | NOT VERIFIED | `shell.json`; no per-plugin test. |
| ONX-8-007 | The lock screen must check the password through PAM `omarchy-lock-password`. | WORKS | `security.pam.services.omarchy-lock-password` in eval. |
| ONX-8-008 | The lock screen must accept a fingerprint through PAM `omarchy-lock-fingerprint`. | PARTIAL | The service exists only when `services.fprintd.enable` is true. Eval: false. |
| ONX-8-009 | The idle service must start the screensaver after 150 s and lock after 300 s. | NOT VERIFIED | `shell.json` idle values. |
| ONX-8-010 | The system-update widget must run `omarchy-update-available` each 6 h. | PARTIAL | The widget works. The result is almost always "updates", because `nixos-unstable` moves often. See ONX-13-008. |
| ONX-8-011 | The polkit agent must show the authentication dialog. | NOT VERIFIED | `security.polkit` is on; plugin present. |
| ONX-8-012 | The weather, speedtest, disk-speedtest, dropbox, tailscale and wifiqr panels must work. | NOT VERIFIED | Not tested. |
| ONX-8-013 | The audio panel and the OSD volume must work. | NOT VERIFIED | The panel uses PipeWire. `pactl` is now present, so the volume commands work (ONX-11-099). Not tested on screen. |
| ONX-8-014 | The clipboard plugin must show the clipboard history. | NOT VERIFIED | `cliphist` is absent; the plugin source was not read. |

## 9. Window manager configuration and key bindings

| ID | Requirement | Status | Evidence |
|---|---|---|---|
| ONX-9-001 | Hyprland must use `programs.hyprland` with `withUWSM` and XWayland. | WORKS | `modules/desktop.nix`. |
| ONX-9-002 | The look must be gaps_in 5, gaps_out 10, border 2 and rounding 0. | WORKS | `default/hypr/looknfeel.lua`. |
| ONX-9-003 | The monitor must use preferred mode, auto position and auto scale. `GDK_SCALE` must be 2. | WORKS | `default/hypr` and skel `monitors.lua`. |
| ONX-9-004 | The keyboard options must be `compose:caps,shift:both_capslock_cancel`. | WORKS | `default/hypr/input.lua`. |
| ONX-9-005 | SUPER+RETURN must open the terminal. | WORKS | VM test sends `meta_l-ret` and finds `foot`. |
| ONX-9-006 | SUPER+SHIFT+RETURN and SUPER+SHIFT+B must open the browser. SUPER+SHIFT+ALT+B must open a private window. | WORKS | Static scan: `omarchy-launch-browser` dependencies present. |
| ONX-9-007 | SUPER+SHIFT+F must open Nautilus. SUPER+ALT+SHIFT+F must open Nautilus in the terminal directory. | WORKS | Static scan. |
| ONX-9-008 | SUPER+SHIFT+N must open the editor. | WORKS | Static scan. `nvim` gets the LazyVim configuration (ONX-5-014). |
| ONX-9-009 | SUPER+ALT+RETURN must open tmux. SUPER+CTRL+RETURN must open herdr. | WORKS | Both commands present. |
| ONX-9-010 | SUPER+SHIFT+M must open Spotify. | WORKS | `omarchy-launch-spotify` now uses `command -v spotify`. See ONX-11-075. |
| ONX-9-011 | SUPER+SHIFT+ALT+M must open cliamp. | WORKS | `cliamp` present. |
| ONX-9-012 | SUPER+SHIFT+D must open the Docker TUI. | NOT VERIFIED | `lazydocker` present; behavior under `pkexec` not checked. |
| ONX-9-013 | SUPER+SHIFT+G must open Signal. | WORKS | `omarchy-launch-signal` now uses `command -v signal-desktop`. See ONX-11-075. |
| ONX-9-014 | SUPER+SHIFT+O must open Obsidian. | WORKS | `obsidian` present with preinstalls. |
| ONX-9-015 | SUPER+SHIFT+W must open Omawrite. | WORKS | The VM test sends SUPER+SHIFT+W and finds the `omawrite` window. |
| ONX-9-016 | SUPER+SHIFT+SLASH must open 1Password. | PARTIAL | 1Password needs a NixOS option. The install prints the options (ONX-11-019). |
| ONX-9-017 | The web app bindings (ChatGPT, Grok, HEY Calendar, HEY Email, YouTube, WhatsApp, Google Messages, Photos, Maps, X) must open web apps. | WORKS | Static scan: `omarchy-launch-webapp` dependencies present. |
| ONX-9-018 | SUPER+SPACE, SUPER+ALT+SPACE, SUPER+CTRL+E, SUPER+CTRL+C, SUPER+CTRL+O and SUPER+CTRL+H must open the menu, apps, emojis, capture, toggle and hardware menus. | WORKS | Shell IPC; VM test opens the main menu. |
| ONX-9-019 | SUPER+ESCAPE and XF86PowerOff must open the system menu. | WORKS | The binding exists. logind ignores the power key (ONX-6-019). |
| ONX-9-020 | SUPER+K, SUPER+ALT+K and SUPER+CTRL+K must show the key binding sheets. | WORKS | Static scan. |
| ONX-9-021 | SUPER+CTRL+Q and XF86Calculator must open Omacalc. | WORKS | The VM test sends SUPER+CTRL+Q and finds the `omacalc` window. |
| ONX-9-022 | SUPER+SHIFT+SPACE, SUPER+CTRL+SPACE and SUPER+SHIFT+CTRL+SPACE must toggle the bar, change the background and open the theme menu. | WORKS | The VM test switches the theme two times and checks `colors.toml` (ONX-10-004). |
| ONX-9-023 | SUPER+BACKSPACE and its variants must toggle transparency, gaps and square corners. | WORKS | Static scan: `hyprctl` only. |
| ONX-9-024 | SUPER+COMMA and its variants must control notifications. | WORKS | Shell IPC. |
| ONX-9-025 | SUPER+CTRL+I must toggle idle. SUPER+CTRL+N must toggle the night light. | WORKS | Shell service; `hyprsunset` present. |
| ONX-9-026 | SUPER+CTRL+DELETE must toggle the laptop display or the mirror. The lid switch must run the lid-close and clamshell actions. | WORKS | Static scan. |
| ONX-9-027 | PRINT must take a screenshot. SUPER+PRINT must pick a color. | WORKS | `tensaku` and `hyprpicker` present. |
| ONX-9-028 | ALT+PRINT must record the screen. | WORKS | `gpu-screen-recorder` and `v4l2-ctl` are present. The webcam overlay is not tested on real hardware. |
| ONX-9-029 | SUPER+CTRL+PRINT must run OCR. | NOT VERIFIED | Tesseract data not checked (ONX-5-013). |
| ONX-9-030 | SUPER+CTRL+S must open the share menu. | WORKS | With preinstalls, `localsend` exists (ONX-5-018). |
| ONX-9-031 | SUPER+CTRL+PERIOD must open the transcode menu. | NOT VERIFIED | `ffmpeg` present; not run. |
| ONX-9-032 | The reminder, time, battery and weather notification bindings must work. | WORKS | Static scan. |
| ONX-9-033 | SUPER+SHIFT+CTRL+A and the SUPER+CTRL panel bindings (A, B, D, ALT+D, W, P) must open the agent and the panels. | NOT VERIFIED | Shell IPC; not tested. |
| ONX-9-034 | SUPER+CTRL+T must open btop. SUPER+CTRL+L must lock. | WORKS | `btop` present; lock PAM present. |
| ONX-9-035 | SUPER+CTRL+X and F9 must start dictation. | BROKEN | `voxtype` is absent until install. The install path is not verified. |
| ONX-9-036 | SUPER+C, SUPER+V and SUPER+X must copy, paste and cut. SUPER+CTRL+V must open the clipboard manager. | NOT VERIFIED | `wl-clipboard` present. `ydotool` and `cliphist` are absent; the scripts were not checked in full. |
| ONX-9-037 | The volume keys must change the volume. | WORKS | `pactl` is present (ONX-5-008). The VM test runs `pactl info`. |
| ONX-9-038 | XF86AudioMicMute must mute the microphone. | WORKS | The binding calls `wpctl`, which is present. |
| ONX-9-039 | SHIFT+XF86AudioMute must switch the audio output. | WORKS | `pactl` is present (ONX-5-008). |
| ONX-9-040 | The brightness and keyboard brightness keys must work. | WORKS | `brightnessctl` present. |
| ONX-9-041 | The touchpad toggle and media keys must work. | WORKS | `hyprctl` and shell media service. |
| ONX-9-042 | XF86Eject must eject the disk. | WORKS | `eject` present. |
| ONX-9-043 | The tiling bindings (close, close all, pseudo, pin, float, fullscreen, focus, workspaces, scratchpad, groups, resize, mouse, scaling) must work. | WORKS | `default/hypr/bindings/tiling.lua`; `hyprctl` only. |

## 10. Themes

| ID | Requirement | Status | Evidence |
|---|---|---|---|
| ONX-10-001 | OmniXY must ship the 22 upstream themes. | WORKS | `OMARCHY_PATH/themes`: catppuccin, catppuccin-latte, ethereal, everforest, flexoki-light, gruvbox, hackerman, kanagawa, last-horizon, lumon, lupine, matte-black, miasma, nord, osaka-jade, retro-82, ristretto, rose-pine, solitude, tokyo-night, vantablack, white. |
| ONX-10-002 | The first login must apply `omnixy.theme`. | WORKS | VM test finds `theme.name`. |
| ONX-10-003 | `omarchy-theme-set <name>` must change `theme.name`. | WORKS | VM test checks `theme.name` after `omarchy-theme-set Catppuccin`. |
| ONX-10-004 | A second `omarchy-theme-set` must replace all theme files. | WORKS | `omnixy-cp` makes the store copies writable. The VM test switches to Catppuccin and then Gruvbox. It finds `colors.toml` and no `next-theme`. |
| ONX-10-005 | `omarchy-theme-set-browser` must set the Chromium theme color through policy. | BROKEN | `PACKAGED_PATH` and the sudoers grant now match. As root, the script sets `PATH=/usr/local/sbin:/usr/local/bin:/usr/bin:/usr/sbin:/bin:/sbin`. NixOS has no `install`, `mktemp` or `rm` there, so the root half fails. |
| ONX-10-006 | `omarchy-theme-set-vscode` must theme VS Code and Cursor. | WORKS | The `/usr/bin/cursor` test is gone. `set_theme "cursor"` runs unless `skip-cursor-theme-changes` is on. |
| ONX-10-007 | `omarchy-theme-set-keyboard-asus-rog` and `omarchy-theme-set-keyboard-f16` must set the keyboard color. | BROKEN | `asusctl` and `qmk_hid` are absent. |
| ONX-10-008 | `omarchy-theme-install` must install a theme from a git URL. | NOT VERIFIED | `git` present; it then calls `omarchy-theme-set`, which works (ONX-10-004). Not run. |
| ONX-10-009 | The background commands must change the background. | WORKS | Shell background plugin; static scan. |
| ONX-10-010 | SDDM must use the `omarchy` theme. | NOT VERIFIED | `services.displayManager.sddm.theme = "omarchy"`; `omnixy-sddm-theme` built. Not seen on screen. |
| ONX-10-011 | SDDM must run on the Hyprland compositor as upstream does. | PARTIAL | The compositor evaluates to `weston`. Upstream uses `start-hyprland -- --config /usr/share/sddm/hyprland.lua`. |
| ONX-10-012 | Style › Unlock and the Plymouth theme commands must change the boot and login look. | PARTIAL | The refresh commands are no-ops. `omarchy-plymouth-set` prints the NixOS option. Style › Unlock is removed. See ONX-11-141. |

## 11. Commands

Command totals in the omarchy package:

| Kind | Count |
|---|---|
| All commands | 455 |
| Stubs | 23 |
| Replacements | 35 (31 `omarchy-*` and 4 `omnixy-*`) |
| Upstream commands with sed patches only | the remainder |

### 11.1 Stubs

Each stub prints a message and exits with code 1. The menu sed hides most of the related entries.

| ID | Requirement | Status | Evidence |
|---|---|---|---|
| ONX-11-001 | `omarchy-upgrade-to-quattro` | STUB | `packages/omarchy/default.nix` archOnly list. |
| ONX-11-002 | `omarchy-refresh-pacman`, `omarchy-refresh-limine` | STUB | archOnly list has `omarchy-refresh-pacman`. `omarchy-refresh-limine` is now a no-op replacement that exits 0. |
| ONX-11-003 | `omarchy-update-keyring`, `omarchy-update-aur-pkgs`, `omarchy-update-pacman-guard`, `omarchy-update-pkg-prune`, `omarchy-update-orphan-pkgs`, `omarchy-update-system-pkgs-when-conflicted` | STUB | archOnly list. `omarchy-update-firmware` is now a replacement (ONX-13-009). |
| ONX-11-004 | `omarchy-pkg-aur-add`, `omarchy-pkg-aur-install`, `omarchy-reinstall-pkgs` | STUB | archOnly list. |
| ONX-11-005 | `omarchy-channel-set` | STUB | archOnly list. |
| ONX-11-006 | `omarchy-dev-pkg-test`, `omarchy-dev-link`, `omarchy-dev-unlink` | STUB | archOnly list. |
| ONX-11-007 | `omarchy-apply-system`, `omarchy-apply-hardware`, `omarchy-provision-owner` | STUB | archOnly list. |
| ONX-11-008 | `omarchy-hibernation-setup`, `omarchy-hibernation-remove` | STUB | archOnly list. |
| ONX-11-009 | `omarchy-toggle-hybrid-gpu` | STUB | archOnly list. |
| ONX-11-010 | `omarchy-snapshot`, `omarchy-system-factory-reset` | STUB | archOnly list. |

### 11.2 Install commands (`omarchy-install-*`)

| ID | Requirement | Status | Evidence |
|---|---|---|---|
| ONX-11-011 | The `omarchy-install-*` commands must install packages through `omarchy-pkg-add`. | PARTIAL | `omarchy-pkg-add` calls `omnixy-pkg add`, which runs `nix profile add --impure`. Rows ONX-11-012 to ONX-11-033 give the result for each command. No install command was run. |
| ONX-11-012 | `omarchy-install-preinstalls` must install the upstream preinstall set. | NOT VERIFIED | All names now resolve: `aether`, `omacut`, `omacalc` and `omawrite` to `omnixy#<name>`, `kdenlive` to `kdePackages.kdenlive`. The install needs the network; not run. |
| ONX-11-013 | `omarchy-install-browser` must install Chrome, Edge, Brave and Zen. | PARTIAL | `omarchy-pkg-aur-add` becomes `omarchy-pkg-add`. Chrome, Edge and Brave map to nixpkgs. `zen-browser-bin` maps to `?`. |
| ONX-11-014 | `omarchy-install-editor-emacs` must install Emacs. | BROKEN | It installs `omarchy-emacs`, which maps to `?`. `docs/spec/gaps.md` lists it as open. |
| ONX-11-015 | `omarchy-install-editor-zed` must install Zed. | NOT VERIFIED | `zed` maps to `zed-editor` and `omazed` to `omnixy#omazed`. Both build or evaluate. The install needs the network; not run. |
| ONX-11-016 | Install › Style › Font must install the 6 Nerd fonts. | NOT VERIFIED | The six `ttf-*-nerd` names map to `nerd-fonts.*`. The install needs the network; not run. |
| ONX-11-017 | `omarchy-install-gaming-retroarch` must install RetroArch with cores and assets. | NOT VERIFIED | `retroarch` maps to `retroarch-full`. The `libretro-*` and `retroarch-assets-*` names map to `-`. Core paths point at the nix profile. Not run. |
| ONX-11-018 | `omarchy-install-gaming-lutris` must install Lutris. | BROKEN | It runs `sudo sed` on `/usr/bin/lutris`. nixpkgs marks a Lutris dependency insecure. `docs/spec/gaps.md` lists it as open. |
| ONX-11-019 | `omarchy-install-service-1password` must install 1Password. | PARTIAL | A replacement prints the NixOS options, with `programs.chromium.extensions`, and exits 1. `omnixy-pkg present` probes `op` and `1password`, so it starts 1Password after the user sets the options. |
| ONX-11-020 | `omarchy-install-service-sunshine` must install Sunshine. | PARTIAL | `omarchy-pkg-add sunshine` prints the option with `openFirewall` and stops. The script skips `ufw` when it is absent. It still reads its icon from `/usr/share/sunshine`. |
| ONX-11-021 | `omarchy-install-service-nordvpn` must install NordVPN. | BROKEN | The package maps to `?`. |
| ONX-11-022 | `omarchy-install-service-once` must install ONCE. | BROKEN | `once-bin` maps to `?`. |
| ONX-11-023 | `omarchy-install-ai-chatgpt` must install the ChatGPT desktop app. | BROKEN | `openai-codex-desktop` maps to `?`. |
| ONX-11-024 | `omarchy-install-ai-t3-code` must install T3 Code. | BROKEN | `t3code-bin` maps to `?`. |
| ONX-11-025 | The Hermes, OpenClaw, Perplexity and Grok Bot installs must work. | BROKEN | `hermes-desktop`, `openclaw`, `perplexity` and `grok-bot` map to `?`. |
| ONX-11-026 | `omarchy-install-gaming-geforce-now` must install GeForce NOW. | PARTIAL | `flatpak` maps to `!services.flatpak.enable = true;`. The command prints the option and stops. After the user sets it, the probe finds `flatpak`. |
| ONX-11-027 | `omarchy-install-gaming-steam` must install and start Steam. | PARTIAL | Steam needs `programs.steam.enable`. The command prints the option. `gtk-launch` is now present. |
| ONX-11-028 | `omarchy-install-service-tailscale` must install and start Tailscale. | PARTIAL | `systemctl enable` acts on a unit that NixOS manages. `services.tailscale.enable` is needed. |
| ONX-11-029 | `omarchy-install-and-launch` must install a program and then start it. | WORKS | Static scan: `gtk-launch` is now present (ONX-5-010). |
| ONX-11-030 | `omarchy-install-dev-env` must install the language runtimes. | PARTIAL | PHP writes `/etc/php`. Prebuilt mise runtimes (node, python, bun, deno) need a dynamic loader; `programs.nix-ld` is false. Go works because it is static. |
| ONX-11-031 | `omarchy-install-docker-dbs` must start the database containers. | NOT VERIFIED | Docker is present and the user is in the `docker` group (ONX-6-011). Not run. |
| ONX-11-032 | `omarchy-install-terminal` must install and set Alacritty, Kitty or Ghostty. | NOT VERIFIED | The packages exist in nixpkgs. Not run. |
| ONX-11-033 | `omarchy-install-and-launch` for the other TUI and desktop apps must work after install. | WORKS | Same as ONX-11-029. |

### 11.3 Remove commands (`omarchy-remove-*`)

| ID | Requirement | Status | Evidence |
|---|---|---|---|
| ONX-11-034 | `omarchy-remove-security-fido2` and `omarchy-remove-security-fingerprint` must remove the PAM setup. | WORKS | Replacements print the NixOS option to remove. They do not edit `/etc/pam.d`. |
| ONX-11-035 | `omarchy-remove-dev-env` must remove a runtime. | NOT VERIFIED | `sudo pacman -Rns` becomes `omarchy-pkg-drop`. Not run. |
| ONX-11-036 | `omarchy-remove-*` for packages must call `omarchy-pkg-drop`. | NOT VERIFIED | `omarchy-pkg-drop` calls `omnixy-pkg drop`; not run. |

### 11.4 Package commands (`omarchy-pkg-*`, `omnixy-pkg`)

| ID | Requirement | Status | Evidence |
|---|---|---|---|
| ONX-11-037 | `omarchy-pkg-add`, `omarchy-pkg-drop`, `omarchy-pkg-present` and `omarchy-pkg-missing` must call `omnixy-pkg`. | WORKS | Replacements in `packages/omarchy/bin`. |
| ONX-11-038 | `omnixy-pkg add` must run `NIXPKGS_ALLOW_UNFREE=1 nix profile add --impure nixpkgs#<attr>`. | NOT VERIFIED | Script text. A value `omnixy#<name>` installs from the `omnixy` registry flake (ONX-13-013). Not run. |
| ONX-11-039 | `omnixy-pkg present` must also check the references of `/run/current-system/sw`. | WORKS | Script text: `nix-store -q --references`. |
| ONX-11-040 | `omnixy-pkg present` must return true for a `!` package after the user sets the NixOS option. | WORKS | `is_present` now uses the `PROBE` table (`op`, `sshd`, `fprintd-list`, `pam_u2f` in `/etc/pam.d/sudo`, `/sys/module/hid_xpadneo` and others). |
| ONX-11-041 | `omnixy-pkg resolve` must map unknown names to the same name after removing `-bin` and `-git`. | WORKS | Script text. |
| ONX-11-042 | `omnixy-pkg` must map the other `omarchy-*` and `oma*` names, `once-bin`, `t3code-bin`, `openai-codex-desktop`, `perplexity`, `grok-bot`, `hermes-desktop` and `openclaw` to `?`. | WORKS | Script text. The `MAP` entries for aether, omacalc, omacut, omawrite, omazed and omarchy-nvim come first and give `omnixy#<name>`. |
| ONX-11-043 | `omarchy-pkg-install` must search nixpkgs with `nix search` and fzf, and install the selection. | NOT VERIFIED | Replacement; `gum` and `fzf` present. Not run. |
| ONX-11-044 | `omarchy-pkg-remove` must list the user profile with fzf and remove the selection. | NOT VERIFIED | Replacement; not run. |
| ONX-11-045 | `omarchy-pkg-declarative` must tell the user how to add a package to the flake. | WORKS | Replacement prints text only. |

### 11.5 Theme commands (`omarchy-theme-*`)

| ID | Requirement | Status | Evidence |
|---|---|---|---|
| ONX-11-046 | `omarchy-theme-set` | WORKS | ONX-10-004. |
| ONX-11-047 | `omarchy-theme-set-browser`, `omarchy-theme-set-browser-policy` | BROKEN | ONX-10-005. |
| ONX-11-048 | `omarchy-theme-set-vscode` | WORKS | ONX-10-006. |
| ONX-11-049 | `omarchy-theme-set-keyboard-asus-rog`, `omarchy-theme-set-keyboard-f16` | BROKEN | ONX-10-007. |
| ONX-11-050 | `omarchy-theme-list`, `omarchy-theme-current`, `omarchy-theme-next`, `omarchy-theme-bg-*` | WORKS | Static scan: all dependencies present. `omarchy-theme-next` calls `omarchy-theme-set`, which works (ONX-10-004). |
| ONX-11-051 | `omarchy-theme-install`, `omarchy-theme-update`, `omarchy-theme-remove` | NOT VERIFIED | `git` present; not run. |

### 11.6 Update commands (`omarchy-update*`)

| ID | Requirement | Status | Evidence |
|---|---|---|---|
| ONX-11-052 | `omarchy-update` | WORKS | Replacement. See section 13. |
| ONX-11-053 | `omarchy-update-system-pkgs` | NOT VERIFIED | Replacement. See ONX-13-002. |
| ONX-11-054 | `omarchy-update-profile-pkgs` | NOT VERIFIED | Replacement. |
| ONX-11-055 | `omarchy-update-available` | PARTIAL | Replacement. See ONX-13-008. |
| ONX-11-056 | `omarchy-update-restart` | NOT VERIFIED | Replacement. See ONX-13-006. |
| ONX-11-057 | `omarchy-update-time` | NOT VERIFIED | It runs `systemctl restart systemd-timesyncd`. The unit exists. |
| ONX-11-058 | `omarchy-update-mise`, `omarchy-update-status` | NOT VERIFIED | Upstream text; `mise` present. |
| ONX-11-059 | `omarchy-update-keyring`, `omarchy-update-aur-pkgs`, `omarchy-update-pacman-guard`, `omarchy-update-pkg-prune`, `omarchy-update-orphan-pkgs`, `omarchy-update-system-pkgs-when-conflicted` | STUB | ONX-11-003. `omarchy-update-firmware` is a replacement (ONX-13-009). |

### 11.7 Version and channel commands

| ID | Requirement | Status | Evidence |
|---|---|---|---|
| ONX-11-060 | `omarchy-version` must print "4.0.6 (OmniXY)". | WORKS | Replacement; VM test runs it. |
| ONX-11-061 | `omarchy-version-channel` must print `nixos-version`. | WORKS | Replacement. |
| ONX-11-062 | `omarchy-version-pkgs` must print the time of the system profile. | WORKS | Replacement uses the profile mtime. |
| ONX-11-063 | `omarchy-channel-current` must print "nixos". | WORKS | Replacement. |
| ONX-11-064 | `omarchy-channel-set` | STUB | ONX-11-005. |

### 11.8 Hardware commands (`omarchy-hw-*`)

| ID | Requirement | Status | Evidence |
|---|---|---|---|
| ONX-11-065 | `omarchy-hw-vulkan` must detect Vulkan support. | WORKS | It now checks `/run/opengl-driver/share/vulkan/icd.d`. |
| ONX-11-066 | The other `omarchy-hw-*` detection commands must work. | WORKS | Static scan: they read `/sys` and `/proc`, and call present commands. |

### 11.9 Hyprland commands (`omarchy-hyprland-*`)

| ID | Requirement | Status | Evidence |
|---|---|---|---|
| ONX-11-067 | The `omarchy-hyprland-*` commands (window, workspace, monitor, gaps, transparency) must control Hyprland. | WORKS | Static scan: `hyprctl` and `jq` present. |
| ONX-11-068 | `omarchy-hyprland-monitor-watch` must react to monitor changes. | NOT VERIFIED | Autostart runs it; no multi-monitor test. |

### 11.10 Launch commands (`omarchy-launch-*`)

| ID | Requirement | Status | Evidence |
|---|---|---|---|
| ONX-11-069 | `omarchy-launch-shell` | WORKS | VM test. |
| ONX-11-070 | `omarchy-launch-browser`, `omarchy-launch-webapp`, `omarchy-launch-editor`, `omarchy-launch-tui`, `omarchy-launch-or-focus` | WORKS | Static scan. |
| ONX-11-071 | `omarchy-launch-docker-tui` | NOT VERIFIED | `lazydocker` present; PATH under `pkexec` not checked. |
| ONX-11-072 | `omarchy-launch-wifi`, `omarchy-launch-bluetooth`, `omarchy-launch-audio` | WORKS | `impala`, `bluetui` and `wiremix` present. |
| ONX-11-073 | `omarchy-launch-screensaver` | NOT VERIFIED | Not run. |
| ONX-11-074 | `omarchy-launch-floating-terminal-with-presentation` | WORKS | Static scan. |
| ONX-11-075 | `omarchy-launch-signal` and `omarchy-launch-spotify` must start the program when it is present. | WORKS | The sed now turns `[[ -x /usr/bin/<name> ]]` into `command -v <name>`. Programs in the user profile also count. |

### 11.11 Restart commands (`omarchy-restart-*`)

| ID | Requirement | Status | Evidence |
|---|---|---|---|
| ONX-11-076 | `omarchy-restart-shell`, `omarchy-restart-wifi`, `omarchy-restart-bluetooth`, `omarchy-restart-pipewire` | WORKS | Static scan: `systemctl` units present. |
| ONX-11-077 | `omarchy-restart-xcompose`, `omarchy-restart-hyprctl` and the other restart commands | WORKS | Static scan. |

### 11.12 Menu commands (`omarchy-menu*`)

| ID | Requirement | Status | Evidence |
|---|---|---|---|
| ONX-11-078 | `omarchy-menu` must open the menu at a given entry. | WORKS | VM test opens the menu. |
| ONX-11-079 | `omarchy-menu-keybindings` must list the key bindings. | WORKS | Static scan. |
| ONX-11-080 | `omarchy-menu-share` must share a file through LocalSend. | WORKS | With preinstalls, `localsend` exists (ONX-5-018). |
| ONX-11-081 | `omarchy-menu-timezone` must set the time zone. | WORKS | ONX-6-029. It runs `sudo timedatectl set-timezone`, and the sudoers rule grants it. |
| ONX-11-082 | The menu entry `setup.reset` must reset the system. | STUB | The menu sed removes `setup.reset`. `omarchy-system-factory-reset` is a stub (ONX-11-010). |

### 11.13 Toggle commands (`omarchy-toggle-*`)

| ID | Requirement | Status | Evidence |
|---|---|---|---|
| ONX-11-083 | `omarchy-toggle-idle`, `omarchy-toggle-nightlight`, `omarchy-toggle-waybar`/bar, `omarchy-toggle-touchpad`, `omarchy-toggle-screensaver` | WORKS | Static scan. |
| ONX-11-084 | `omarchy-toggle-hybrid-gpu` | STUB | ONX-11-009. |

### 11.14 Refresh and reinstall commands (`omarchy-refresh-*`, `omarchy-reinstall*`)

| ID | Requirement | Status | Evidence |
|---|---|---|---|
| ONX-11-085 | `omarchy-refresh-config` must copy one default file into the user config. | NOT VERIFIED | Its `cp` calls now go through `omnixy-cp`, so the copies are writable. Not run. |
| ONX-11-086 | `omarchy-reinstall-configs` must restore all default configurations. | NOT VERIFIED | A replacement runs `omnixy-seed-user --force` and then `omarchy-nvim-setup --force`. It does not call a stub. Not run. |
| ONX-11-087 | `omarchy-reinstall` must reinstall OmniXY. | NOT VERIFIED | A replacement asks for confirmation and runs `omarchy-reinstall-configs`. NixOS declares the packages. Not run. |
| ONX-11-088 | `omarchy-refresh-pacman`, `omarchy-refresh-limine` | STUB | ONX-11-002. `omarchy-refresh-limine` is now a no-op replacement. |
| ONX-11-089 | `omarchy-refresh-sddm`, `omarchy-refresh-plymouth` | WORKS | Replacements exit 0. NixOS declares SDDM and Plymouth, and `omarchy-update` rebuilds them. |

### 11.15 System commands (`omarchy-system-*`, power)

| ID | Requirement | Status | Evidence |
|---|---|---|---|
| ONX-11-090 | The system menu actions lock, suspend, restart and shut down must work. | WORKS | Static scan: `systemctl` and the lock present. |
| ONX-11-091 | The system menu must hide hibernate. | WORKS | Menu sed removes `system.hibernate`. |
| ONX-11-092 | `omarchy-system-factory-reset` | STUB | ONX-11-010. |
| ONX-11-093 | `omarchy-powerprofiles-init` and the power profile commands | WORKS | `powerprofilesctl` present. |

### 11.16 Development commands (`omarchy-dev-*`)

| ID | Requirement | Status | Evidence |
|---|---|---|---|
| ONX-11-094 | `omarchy-dev-pkg-test`, `omarchy-dev-link`, `omarchy-dev-unlink` | STUB | ONX-11-006. |
| ONX-11-095 | `omarchy-debug` must print system information. | WORKS | The sed replaces the `pacman -Q` and `expac` calls with `omarchy-version` and `omnixy-pkg list`. |
| ONX-11-096 | `omarchy-upload-log` must upload the logs. | WORKS | The sed replaces `pacman -Q` with `omnixy-pkg list`. |

### 11.17 Plugin and extension commands

| ID | Requirement | Status | Evidence |
|---|---|---|---|
| ONX-11-097 | The shell plugin and extension commands must load the user extensions in `~/.config/omarchy/extensions`. | NOT VERIFIED | Skel holds the directory; not run. |

### 11.18 Audio commands (`omarchy-audio-*`)

| ID | Requirement | Status | Evidence |
|---|---|---|---|
| ONX-11-098 | `omarchy-audio-output-sink` must print the current sink. | WORKS | `pactl` is present (ONX-5-008). |
| ONX-11-099 | `omarchy-audio-output-volume` must change the volume. | WORKS | `pactl` is present (ONX-5-008). The VM test runs `pactl info`. |
| ONX-11-100 | `omarchy-audio-output-switch` must switch the output. | WORKS | `pactl` is present (ONX-5-008). |
| ONX-11-101 | `omarchy-audio-input-set-default` and the sink availability check must work. | WORKS | `pactl` is present (ONX-5-008). |
| ONX-11-102 | `omarchy-audio-tuning` must apply the speaker tuning. | BROKEN | `pactl` is present. The script checks `/usr/lib/lv2/lsp-plugins.lv2/limiter_stereo.ttl`. NixOS has no `/usr/lib/lv2`, so it stops with "lsp-plugins-lv2 is required". |
| ONX-11-103 | The microphone mute command must work. | WORKS | It calls `wpctl`. |

### 11.19 Capture commands (`omarchy-capture-*`)

| ID | Requirement | Status | Evidence |
|---|---|---|---|
| ONX-11-104 | `omarchy-capture-screenshot` must take a screenshot with tensaku. | WORKS | `tensaku`, `grim` and `slurp` present. |
| ONX-11-105 | `omarchy-capture-screenrecording` must record the screen. | WORKS | `gpu-screen-recorder` present; `programs.gpu-screen-recorder` sets the `gsr-kms-server` wrapper. |
| ONX-11-106 | `omarchy-capture-screenrecording` with the webcam and `omarchy-capture-webcam-list` must list and use webcams. | NOT VERIFIED | `v4l2-ctl` is now present. No webcam test. |
| ONX-11-107 | `omarchy-capture-colorpicker` | WORKS | `hyprpicker` present. |
| ONX-11-108 | `omarchy-capture-ocr` | NOT VERIFIED | ONX-5-013. |

### 11.20 Plymouth and boot commands

| ID | Requirement | Status | Evidence |
|---|---|---|---|
| ONX-11-141 | `omarchy-plymouth-set`, `omarchy-plymouth-reset`, `omarchy-refresh-plymouth`, `omarchy-refresh-sddm` and Style › Unlock must change the boot and login look. | PARTIAL | `omarchy-plymouth-set` and `omarchy-plymouth-reset` print the NixOS option. `omarchy-refresh-plymouth` and `omarchy-refresh-sddm` exit 0. The menu sed removes Style › Unlock. No run-time change occurs. |
| ONX-11-109 | `omarchy-plymouth-current` must show the current logo. | WORKS | It reads `/run/current-system/sw/share/plymouth/themes/omarchy/logo.png`. `modules/system.nix` puts the theme in the system profile when `features.plymouth` is on. |
| ONX-11-110 | `omarchy-setup-direct-boot` must create a UEFI boot entry. | BROKEN | `efibootmgr` is now present. The script still needs an omarchy UKI in `/boot/EFI/Linux`. NixOS does not make one. |
| ONX-11-111 | `omarchy-drive-password` must change the disk password. | NOT VERIFIED | `cryptsetup` is now present. It needs a LUKS disk; not run. |

### 11.21 Agent commands (`omarchy-agent*`)

| ID | Requirement | Status | Evidence |
|---|---|---|---|
| ONX-11-112 | The agent commands must start and list AI agents. | NOT VERIFIED | Shell agents plugin; agent CLIs depend on ONX-4-027. |

### 11.22 Notification commands (`omarchy-notification*`)

| ID | Requirement | Status | Evidence |
|---|---|---|---|
| ONX-11-113 | The notification commands must send and dismiss notifications. | WORKS | Shell notifications plugin; `notify-send` present. |

### 11.23 Web app and TUI commands

| ID | Requirement | Status | Evidence |
|---|---|---|---|
| ONX-11-114 | `omarchy-webapp-install` must create a web app desktop file. | WORKS | `gtk-update-icon-cache` is now present (ONX-5-010). |
| ONX-11-115 | `omarchy-tui-install` must create a TUI desktop file. | WORKS | Same as ONX-11-114. |
| ONX-11-116 | `omarchy-webapp-remove` and `omarchy-tui-remove` must remove the desktop file. | WORKS | Static scan. |
| ONX-11-117 | `omarchy-webapp-handler-hey` and `omarchy-webapp-handler-zoom` must handle `mailto` and Zoom URLs. | WORKS | Static scan: both commands exist and call `omarchy-launch-webapp`. The first audit named a command that upstream does not have. |
| ONX-11-118 | `omarchy-refresh-applications` must copy the default desktop files. | WORKS | Its `cp` calls go through `omnixy-cp`, so a second run can overwrite the copies. The VM test proves `omnixy-cp` in the theme switch. |

### 11.24 Voxtype commands (`omarchy-voxtype-*`)

| ID | Requirement | Status | Evidence |
|---|---|---|---|
| ONX-11-119 | The voxtype commands must start dictation. | BROKEN | `voxtype` is absent until install. The install was not run. |

### 11.25 Setup commands (`omarchy-setup-*`)

| ID | Requirement | Status | Evidence |
|---|---|---|---|
| ONX-11-120 | `omarchy-setup-security-fido2` must tell the user the NixOS options for FIDO2. | WORKS | Replacement prints options. |
| ONX-11-121 | `omarchy-setup-security-fingerprint` must tell the user the NixOS options for the fingerprint reader. | WORKS | Replacement prints options. |
| ONX-11-122 | `omarchy-setup-security-sshd` must enable the SSH server. | PARTIAL | The `sshd` probe finds the server after the user sets `services.openssh.enable`. Before that, the script prints the option and stops. It skips `ufw` when it is absent. |
| ONX-11-123 | `omarchy-sudo-passwordless` must enable sudo without a password. | WORKS | `modules/tuning.nix` adds `@includedir /etc/sudoers.d` and a tmpfiles `r!` rule for the timed files. |
| ONX-11-124 | `omarchy-windows-vm` must install and start a Windows VM. | BROKEN | The `/usr/bin` paths are gone. As root, the script sets `PATH=/usr/bin:/usr/sbin:/bin:/sbin`. NixOS has no tools there, so the root half fails. `xfreerdp3` is not verified. |
| ONX-11-125 | The default-program setup entries must set Helix and Sublime as editors. | PARTIAL | Helix installs `hx`, so the `WHEN` condition hides the entry. Sublime installs `subl`. |

### 11.26 Network commands (`omarchy-network-*`, `omarchy-dns`)

| ID | Requirement | Status | Evidence |
|---|---|---|---|
| ONX-11-126 | `omarchy-network-status` and `omarchy-network-band` must show the Wi-Fi band. | NOT VERIFIED | `iw` is now present. No Wi-Fi hardware test. |
| ONX-11-127 | `omarchy-dns` (Setup › Network › DNS) must change the DNS server. | BROKEN | `PACKAGED_PATH` and the sudoers grant now match; the VM test runs `sudo -n -l`. As root, the script sets `PATH=/usr/local/sbin:/usr/local/bin:/usr/bin:/usr/sbin:/bin:/sbin`. NixOS has no `install`, `nmcli` or `awk` there, so the root half fails. |

### 11.27 Helper commands (`omarchy-cmd-*`)

| ID | Requirement | Status | Evidence |
|---|---|---|---|
| ONX-11-128 | `omarchy-cmd-present`, `omarchy-cmd-missing`, `omarchy-cmd-terminal-cwd` | WORKS | Static scan; `/etc/shells` match (ONX-6-032). |
| ONX-11-129 | `omarchy-cmd-browser-handoff` must hand a URL to the running browser. | WORKS | The sed matches the browser by `basename`, so `chromium` matches. |
| ONX-11-130 | The other `omarchy-cmd-*` helpers (share, screensaver, apps, reminder) | WORKS | Static scan. |

### 11.28 Brightness commands (`omarchy-brightness-*`)

| ID | Requirement | Status | Evidence |
|---|---|---|---|
| ONX-11-131 | The brightness commands must change screen and keyboard brightness. | WORKS | `brightnessctl` and `ddcutil` present. |

### 11.29 Default-program and mise commands

| ID | Requirement | Status | Evidence |
|---|---|---|---|
| ONX-11-132 | `omarchy-mise-install` must install a mise tool. | NOT VERIFIED | `mise` present. Prebuilt binaries need nix-ld, which is off. |
| ONX-11-133 | `omarchy-default-*` commands must set the default browser, terminal and editor. | WORKS | Static scan. |

### 11.30 Other replacements

| ID | Requirement | Status | Evidence |
|---|---|---|---|
| ONX-11-134 | `omarchy-apply-lock` must do nothing and exit 0. | WORKS | Replacement. |
| ONX-11-135 | `omnixy-seed-user` | WORKS | ONX-4-012. |
| ONX-11-136 | `omnixy-session` | WORKS | ONX-4-011. |
| ONX-11-137 | `omarchy commands` must list the commands. | WORKS | VM test runs it. |
| ONX-11-138 | `omarchy-apply-system`, `omarchy-apply-hardware`, `omarchy-provision-owner` | STUB | ONX-11-007. |
| ONX-11-139 | `omarchy-hibernation-setup`, `omarchy-hibernation-remove`, `omarchy-snapshot` | STUB | ONX-11-008, ONX-11-010. |
| ONX-11-140 | All other upstream commands must find their dependencies. | WORKS | Static scan found no missing command for the remaining launch, toggle, hyprland, capture, nightlight, power, restart and webapp scripts. This is a static result only. |

## 12. Applications and web apps

| ID | Requirement | Status | Evidence |
|---|---|---|---|
| ONX-12-001 | The default browser must be Chromium. | WORKS | `programs.chromium.enable`; `/etc/xdg/mimeapps.list`. |
| ONX-12-002 | The default terminal must be foot. | WORKS | VM test. |
| ONX-12-003 | The default file manager must be Nautilus with "open in terminal" for foot. | WORKS | `programs.nautilus-open-any-terminal`. |
| ONX-12-004 | The preinstalled desktop apps (LibreOffice, Obsidian, OBS, Kdenlive, Pinta, Xournal++, LocalSend, Moonlight) must start. | NOT VERIFIED | Packages present, with aether, omacalc, omacut and omawrite. Not started, except omacalc and omawrite (ONX-12-007). |
| ONX-12-005 | LocalSend must start from the scripts. | WORKS | ONX-5-018. |
| ONX-12-006 | The 17 skel desktop files (Basecamp, Discord, Disk Usage, Docker, foot, Google Contacts, Maps, Messages, Photos, HEY, imv, mpv, omarchy-browser, WhatsApp, X, YouTube, Zoom) must start their targets. | WORKS | Web apps open through Chromium. The icons are present (ONX-7-008). |
| ONX-12-007 | The Oma apps must be available. | WORKS | ONX-5-015. |
| ONX-12-008 | The LazyVim editor configuration must be available. | WORKS | ONX-5-014. |
| ONX-12-009 | `localsend` must have its firewall port 53317 open. | WORKS | `modules/services.nix`; `programs.localsend`. |
| ONX-12-010 | The 1Password, Signal and Spotify bindings must start the program after install. | PARTIAL | Signal and Spotify work (ONX-11-075). 1Password needs a NixOS option (ONX-11-019). |

## 13. Update and package management

| ID | Requirement | Status | Evidence |
|---|---|---|---|
| ONX-13-001 | `omarchy-update` must log to `/tmp/omarchy-update.log`, ask for confirmation and keep the system awake. | NOT VERIFIED | Replacement text; not run. |
| ONX-13-002 | `omarchy-update-system-pkgs` must run `nix flake update --flake $OMNIXY_FLAKE` and `sudo nixos-rebuild switch --flake $flake#$host`. | NOT VERIFIED | Replacement text. The host defaults to `hostname`. Not run. |
| ONX-13-003 | `omarchy-update-system-pkgs` must use sudo only when the flake directory is not writable. | NOT VERIFIED | `maybe_sudo` in the script. |
| ONX-13-004 | `omarchy-update-profile-pkgs` must upgrade the user profile. | NOT VERIFIED | Replacement text. |
| ONX-13-005 | `omarchy-update` must then run migrations, the `post-update` hook, `omarchy-update-mise` and `omarchy-update-status`. | NOT VERIFIED | Replacement text. |
| ONX-13-006 | `omarchy-update-restart` must ask for a reboot when the kernel or Hyprland changed. | NOT VERIFIED | It compares `/run/booted-system` and `/run/current-system`, and the Hyprland store paths. |
| ONX-13-007 | `omarchy-update-restart` must restart the shell. | NOT VERIFIED | It calls `omarchy-restart-shell`. |
| ONX-13-008 | `omarchy-update-available` must exit 0 only when an update is available. | PARTIAL | It runs `git ls-remote` for each GitHub root input in `flake.lock`. `nixos-unstable` moves often, so it almost always reports updates. |
| ONX-13-009 | Firmware update through the menu must work. | NOT VERIFIED | A replacement `omarchy-update-firmware` runs `fwupdmgr refresh` and `fwupdmgr update`. The menu entry is back. It needs real hardware; not run. |
| ONX-13-010 | AUR package management must be absent. | WORKS | Stubs and menu sed. AUR names in the install scripts go through `omarchy-pkg-add` (ONX-11-013). |
| ONX-13-011 | Release channel selection must be absent. | WORKS | `omarchy-channel-set` stub; menu sed. |
| ONX-13-012 | `omarchy-migrate` must run new migrations once. | NOT VERIFIED | 120 markers seeded; not run. |
| ONX-13-013 | The flake must register itself as `omnixy` in the Nix registry, so `omnixy-pkg` installs the Oma apps from the same source. | WORKS | `flake.nix` sets `nix.registry.omnixy.flake = self`. The VM test runs `nix registry list`. |
| ONX-13-014 | `omnixy-pkg list` must print the installed system and profile packages with their versions. | WORKS | Script text: `nix-store -q --references` and `nix profile list --json`. `omarchy-debug` and `omarchy-upload-log` call it. |

## 14. Hardware support

| ID | Requirement | Status | Evidence |
|---|---|---|---|
| ONX-14-001 | The system must enable redistributable firmware and the wireless regulatory database. | WORKS | Eval. |
| ONX-14-002 | `hardware.graphics` must be on. | WORKS | Eval. |
| ONX-14-003 | The upstream hardware quirks in `install/hardware` (Apple, ASUS, Dell, Framework, Surface, NVIDIA, Intel and others) must apply. | BROKEN | No NixOS module mirrors them. `REPORT.md` lists this item. |
| ONX-14-004 | Hybrid GPU switch must work. | STUB | ONX-11-009. |
| ONX-14-005 | Hibernation must work. | STUB | ONX-11-008. |
| ONX-14-006 | `thermald` must run on Intel systems. | WORKS | `modules/tuning.nix` enables `thermald` when `hardware.cpu.intel.updateMicrocode` is true. Eval on the example host: false (no Intel microcode set). |
| ONX-14-007 | `fprintd` must be available for fingerprint readers. | PARTIAL | Option only; default off. The setup command prints the option. |
| ONX-14-008 | ASUS and Framework keyboard lights must work. | BROKEN | ONX-10-007. |
| ONX-14-009 | The Xbox controller driver `xpadneo` must install. | PARTIAL | It maps to `!`; the command prints the option. The probe tests `/sys/module/hid_xpadneo` (ONX-11-040). |
| ONX-14-010 | `tlp` must not run. | WORKS | Eval false; `power-profiles-daemon` runs. |
| ONX-14-011 | The kernel must be 6.18. | WORKS | Eval: 6.18.60. |
| ONX-14-012 | Behavior on real hardware must be known. | NOT VERIFIED | `REPORT.md`: no test on real hardware. |

## 15. Security

| ID | Requirement | Status | Evidence |
|---|---|---|---|
| ONX-15-001 | The firewall must be on. | WORKS | `networking.firewall` with `features.firewall`. |
| ONX-15-002 | sudo must ask for a password for the wheel group. | WORKS | `wheelNeedsPassword` true. |
| ONX-15-003 | sudo must allow the upstream rules in `/etc/sudoers.d` (`omarchy-dns`, `omarchy-theme-browser`, `omarchy-tzupdate`, `passwd-tries`). | WORKS | `modules/tuning.nix` sets `passwd_tries=10`, `@includedir` and NOPASSWD grants for `omarchy-dns`, `omarchy-theme-set-browser-policy` and `timedatectl set-timezone`. The VM test runs `sudo -n -l` for `omarchy-dns`. |
| ONX-15-004 | faillock must lock the account after 10 failures for 120 s. | BROKEN | The dead `faillock.conf` is removed. No PAM stack has `pam_faillock`, so there is no lockout. `docs/spec/gaps.md` lists it as open. |
| ONX-15-005 | Login must not add a delay after a failure. | WORKS | `failDelay` false. |
| ONX-15-006 | The kernel must load the LSMs `landlock`, `yama` and `bpf`. | WORKS | Eval kernelParams. |
| ONX-15-007 | GNOME Keyring must provide the Secret portal. | WORKS | `modules/desktop.nix`; wrapper `gnome-keyring-daemon`. |
| ONX-15-008 | SDDM must unlock GNOME Keyring at login. | PARTIAL | `sddm.enableGnomeKeyring` is false. `install/user/default-keyring.sh` creates the default keyring; not run. |
| ONX-15-009 | The SSH server must be off by default. | WORKS | Eval `services.openssh.enable` false. |
| ONX-15-010 | FIDO2 and fingerprint login must be available through options. | WORKS | The setup and remove commands print the options (ONX-11-034). |
| ONX-15-011 | The setuid wrappers must include `sudo`, `su`, `pkexec`, `passwd`, `chsh`, `unix_chkpwd`, `gsr-kms-server` and `plocate`. | WORKS | `/run/wrappers` eval. |
| ONX-15-012 | `pkexec` must work for the scripts that call it. | NOT VERIFIED | Wrapper present; PATH under `pkexec` not checked. |
| ONX-15-013 | The removal of upstream NOPASSWD sudoers files at boot must exist. | WORKS | `modules/tuning.nix` tmpfiles rule `r! /etc/sudoers.d/99-omarchy-nopasswd-*`. |

## 16. Testing and development tooling

| ID | Requirement | Status | Evidence |
|---|---|---|---|
| ONX-16-001 | `checks.example` must build the example toplevel. | WORKS | `flake.nix`. |
| ONX-16-002 | `checks.desktop` must start the session through SDDM autologin. | WORKS | `tests/desktop.nix`. The VM test passes all subtests after PR #4. |
| ONX-16-003 | The VM test must check the seed files, `quickshell`, the terminal binding, the menu binding, a theme change, `omarchy-version` and `omarchy commands`. | PARTIAL | The test checks these items and also a second theme switch with `colors.toml`. The menu check is still a screenshot only. |
| ONX-16-004 | The dev shell must give `nixfmt`, `nil`, `statix`, `deadnix` and `shellcheck`. | WORKS | `flake.nix`. |
| ONX-16-005 | `nix run .#vm` must start the VM. | NOT VERIFIED | `apps.vm`; not run. |
| ONX-16-006 | The tests must cover audio, theme files, the share menu and the install commands. | PARTIAL | The VM test now covers `pactl`, the theme files, sudo, sysctl, the `docker` group, an icon, the Oma apps and the registry. No test covers the share menu or the install commands. |
| ONX-16-007 | `omarchy-dev-*` must give a development link to a local checkout. | STUB | ONX-11-006. |
