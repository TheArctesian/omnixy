# Omarchy v4.0.6 project specification

This document uses ASD-STE100 Simplified Technical English.
The source is the `basecamp/omarchy` repository at tag `v4.0.6` (commit `237f1b40`).
All source paths are relative to the repository root.

## 1. Scope

| ID | Requirement | Source |
|---|---|---|
| OMA-1-001 | This specification must describe the Omarchy v4.0.6 distribution as the repository files define it. | (whole repository) |
| OMA-1-002 | The specification covers the files in `bin/`, `install/`, `default/`, `config/`, `etc/`, `applications/`, `themes/`, `shell/`, `migrations/` and `test/`. | docs/file-layout.md |
| OMA-1-003 | The specification does not cover the ISO builder, the `omarchy-pkgs` PKGBUILDs or the `omarchy-iso` repository. These are not in this repository. | docs/file-layout.md |
| OMA-1-004 | The specification does not cover behavior of upstream packages (for example Hyprland or Quickshell) except where Omarchy configures them. | (scope decision) |
| OMA-1-005 | The `version` file contains `4.0.0.alpha`. The git tag is `v4.0.6`. The reason for the difference is not determined. | version |
| OMA-1-006 | The command function text in section 11 is the `omarchy:summary` metadata of each command. The text is quoted as source data and is not rewritten into STE. | bin/* |
| OMA-1-007 | The menu labels and binding descriptions are quoted from the source files as source data. | default/omarchy/omarchy-menu.jsonc; default/hypr/bindings/*.lua |
| OMA-1-008 | Each requirement has the ID form `OMA-<section>-<nnn>`. | (this document) |
| OMA-1-009 | An item that the files do not make clear has the text "not determined". | (this document) |

## 2. Definitions

| ID | Term | Definition |
|---|---|---|
| OMA-2-001 | Omarchy | The Arch Linux distribution with the Hyprland compositor that this repository defines. |
| OMA-2-002 | `OMARCHY_PATH` | The environment variable that holds the Omarchy install directory. The default value is `/usr/share/omarchy`. |
| OMA-2-003 | command | An executable file in `bin/` with a name that starts with `omarchy`. |
| OMA-2-004 | command group | The group token of a command. The `omarchy:group` metadata or the second token of the file name sets it. |
| OMA-2-005 | router | The `omarchy` command. It lists the command groups and runs `omarchy-<group>-<name>` commands. |
| OMA-2-006 | hidden command | A command with `omarchy:hidden=true` metadata. The router does not show it. |
| OMA-2-007 | shell | The single Quickshell process that runs `$OMARCHY_PATH/shell`. It draws the desktop interface. |
| OMA-2-008 | plugin | A shell module with a `manifest.json` file. A plugin has a kind: bar, bar-widget, menu, overlay, panel or service. |
| OMA-2-009 | bar | The plugin `omarchy.bar`. It shows a strip at the top of each monitor. |
| OMA-2-010 | bar widget | A plugin item that the bar shows in its left, center or right area. |
| OMA-2-011 | panel | A shell surface that opens from a bar widget or from a key binding. |
| OMA-2-012 | overlay | A full-screen shell surface, for example the emoji picker or the clipboard manager. |
| OMA-2-013 | shell service | A plugin without a surface that supplies state, for example battery or idle. |
| OMA-2-014 | OSD | The on-screen display plugin `omarchy.osd`. It shows volume, brightness and similar values. |
| OMA-2-015 | menu | The Omarchy menu. The file `default/omarchy/omarchy-menu.jsonc` defines its entries. |
| OMA-2-016 | theme | A directory in `themes/` or in `~/.config/omarchy/themes/` that contains `colors.toml` and backgrounds. |
| OMA-2-017 | template | A file in `default/themed/` that the theme engine fills with theme colors. |
| OMA-2-018 | background | An image file in the `backgrounds` directory of a theme or in `~/.config/omarchy/backgrounds/<theme>`. |
| OMA-2-019 | state directory | The directory `~/.local/state/omarchy`. |
| OMA-2-020 | toggle | A flag file in `~/.local/state/omarchy/toggles/` that turns a feature on or off. |
| OMA-2-021 | flag file | An empty file whose presence sets a state. |
| OMA-2-022 | migration | A shell script in `migrations/` with a Unix timestamp name. It changes an existing user setup one time. |
| OMA-2-023 | hook | A user script in `~/.config/omarchy/hooks/<name>` or `<name>.d/` that a command runs at an event. |
| OMA-2-024 | seed | The files in `/etc/skel` that `useradd -m` copies into a new home directory. |
| OMA-2-025 | finalization | The step `omarchy-provision-user` that completes the user setup after the seed. |
| OMA-2-026 | first-run | The step `omarchy-provision-first-run` that runs at the first graphical login. |
| OMA-2-027 | resync | The command `omarchy-reinstall-configs`. It copies `/etc/skel` over the home directory again. |
| OMA-2-028 | provisioning | The steps that create the owner account and set the system identity. |
| OMA-2-029 | deferred provisioning | An install mode that asks for the owner account at the first boot, not in the ISO. |
| OMA-2-030 | factory reset | The procedure that replaces the root subvolume with the `@factory` snapshot. |
| OMA-2-031 | ISO | The Omarchy installer image. A separate repository builds it. |
| OMA-2-032 | install user | The user account that the ISO creates. |
| OMA-2-033 | channel | The package source of Omarchy: `stable`, `rc`, `edge` or `dev`. |
| OMA-2-034 | OPR | The Omarchy package repository at `https://pkgs.omarchy.org`. |
| OMA-2-035 | AUR | The Arch User Repository. The `yay` helper installs from it. |
| OMA-2-036 | web app | A desktop entry that opens a URL in a Chromium app window through `omarchy-launch-webapp`. |
| OMA-2-037 | TUI | A terminal application that a desktop entry or a binding opens in a terminal window. |
| OMA-2-038 | preinstall | An application that Omarchy installs by default and that `omarchy-remove-preinstalls` can remove. |
| OMA-2-039 | dev link | The development mode that points `OMARCHY_PATH` to a git checkout through `/etc/omarchy.conf`. |
| OMA-2-040 | update lock | The lock file `$XDG_RUNTIME_DIR/omarchy-update.lock`. |
| OMA-2-041 | snapshot | A Btrfs snapshot that `snapper` makes of the root subvolume. |
| OMA-2-042 | session | The Hyprland session that `uwsm` starts from `omarchy.desktop`. |
| OMA-2-043 | uwsm | The Universal Wayland Session Manager. It starts Hyprland and applications as systemd units. |
| OMA-2-044 | quirk | A hardware-specific install script in `install/hardware/`. |
| OMA-2-045 | key binding | A Hyprland key combination that a file in `default/hypr/bindings/` defines. |

## 3. System overview and architecture

### Packages and file layout

| ID | Requirement | Source |
|---|---|---|
| OMA-3-001 | The `omarchy` package must install `bin/`, `install/`, `migrations/`, `themes/`, `shell/` and `version` to `/usr/share/omarchy`. | docs/file-layout.md |
| OMA-3-002 | The `omarchy` package must depend on `omarchy-settings`. | docs/file-layout.md |
| OMA-3-003 | The `omarchy-settings` package must install `/etc/skel/**`, the `/etc` drop-ins, `default/**`, fonts, the Plymouth theme, the SDDM theme, the Limine files and the Snapper template. | docs/file-layout.md |
| OMA-3-004 | The `omarchy-settings` package must install `config/**` to `/etc/skel/.config/**`. | docs/file-layout.md |
| OMA-3-005 | The `omarchy-settings` package must install `applications/*.desktop` to `/etc/skel/.local/share/applications/`. | docs/file-layout.md |
| OMA-3-006 | The `omarchy-settings` package must install `applications/icons/*` to `/usr/share/icons/hicolor/`. | docs/file-layout.md |
| OMA-3-007 | The `omarchy-settings` package must install `default/snapper/root` to `/etc/snapper/config-templates/omarchy`. | docs/file-layout.md |
| OMA-3-008 | The `omarchy-settings` post-install script must copy override files (for example `/etc/skel/.bashrc` and `nsswitch.conf`) with `cp -f`. | docs/file-layout.md |
| OMA-3-009 | The `omarchy-settings` package must seed the migration state in `/etc/skel/.local/state/omarchy/migrations/`. | docs/file-layout.md |
| OMA-3-010 | The edge and dev channels must use the packages `omarchy-dev` and `omarchy-settings-dev`. | bin/omarchy-channel-set |
| OMA-3-011 | The packages `omarchy-keyring` and `omarchy-nvim` must be separate packages. | install/omarchy-base.packages; bin/omarchy-update-keyring |

### Home directory layers

| ID | Requirement | Source |
|---|---|---|
| OMA-3-012 | Layer 1 (seed) must supply the static defaults through `/etc/skel`. | docs/file-layout.md |
| OMA-3-013 | Layer 2 (finalization) must do the user setup that needs `$HOME` expansion or live tools. | bin/omarchy-provision-user |
| OMA-3-014 | Layer 3 (resync) must copy `/etc/skel/.` over `$HOME` with `cp -af` on user request. | bin/omarchy-reinstall-configs |
| OMA-3-015 | The resync must also run the Limine refresh, the Plymouth refresh and the Neovim refresh. | bin/omarchy-reinstall-configs |
| OMA-3-016 | The resync must overwrite user changes. It is destructive. | bin/omarchy-reinstall-configs |

### Environment bootstrap

| ID | Requirement | Source |
|---|---|---|
| OMA-3-017 | The file `default/bash/env-bootstrap` must source `/etc/omarchy.conf` when it exists. | default/bash/env-bootstrap |
| OMA-3-018 | If `/etc/omarchy.conf` does not exist, `env-bootstrap` must set `OMARCHY_PATH=/usr/share/omarchy`. | default/bash/env-bootstrap |
| OMA-3-019 | `/etc/profile.d/omarchy.sh`, `/etc/skel/.bashrc`, `/usr/share/uwsm/env.d/10-omarchy` and `default/bash/envs` must source `env-bootstrap`. | etc/profile.d; default/uwsm; default/bash |
| OMA-3-020 | The dev link must write `/etc/sudoers.d/omarchy-dev-path` so that `sudo` keeps the dev `OMARCHY_PATH`. | bin/omarchy-dev-link |

### Runtime components

| ID | Component | Function | Source |
|---|---|---|---|
| OMA-3-021 | Hyprland | Wayland compositor and window manager. Lua configuration. | default/hypr/ |
| OMA-3-022 | uwsm | Starts the session and wraps applications as systemd units. | default/wayland-sessions/omarchy.desktop |
| OMA-3-023 | Quickshell (`omarchy-shell`) | Bar, menu, notifications, OSD, lock screen, idle, panels. | shell/shell.qml |
| OMA-3-024 | SDDM | Login manager with the Wayland greeter in Hyprland. | etc/sddm.conf.d |
| OMA-3-025 | Limine | Bootloader with UKI and snapshot entries. | etc/limine-entry-tool.d; default/limine |
| OMA-3-026 | Snapper | Btrfs snapshots of the root subvolume. | install/config/snapper.sh |
| OMA-3-027 | Plymouth | Boot splash with the `omarchy` theme. | etc/plymouth; default/plymouth |
| OMA-3-028 | foot | Default terminal. | default/xdg-terminal-exec |
| OMA-3-029 | Chromium | Default browser and web app runtime. | install/user/chromium.sh |
| OMA-3-030 | Neovim (`omarchy-nvim`) | Default editor. | install/omarchy-base.packages |
| OMA-3-031 | mise | Tool and language runtime manager. | install/user/mise.sh |
| OMA-3-032 | fcitx5 | Input method framework. | default/environment.d |

### Setup contexts

| ID | Requirement | Source |
|---|---|---|
| OMA-3-033 | The variable `OMARCHY_SETUP_CONTEXT` must have one of the values `runtime`, `iso-chroot` or `provision-owner`. | install/helpers |
| OMA-3-034 | Install scripts must change their behavior on the setup context, for example to skip GUI calls in `iso-chroot`. | install/user/theme.sh |

## 4. Installation and provisioning

### ISO installation flow

| ID | Requirement | Source |
|---|---|---|
| OMA-4-001 | The ISO must pacstrap the packages in `install/omarchy-base.packages`. | install/omarchy-base.packages |
| OMA-4-002 | The ISO must run `omarchy-apply-system` as root in the chroot. | bin/omarchy-apply-system |
| OMA-4-003 | `omarchy-apply-system` must accept `--install-user USER` with `--first-install` or `--upgrade`. | bin/omarchy-apply-system |
| OMA-4-004 | `omarchy-apply-system` must accept `--defer-provisioning`. | bin/omarchy-apply-system |
| OMA-4-005 | `omarchy-apply-system` must source `install/config/all.sh`, then run `omarchy-apply-hardware`, then source `install/login/all.sh`, then `install/post-install/all.sh`. | bin/omarchy-apply-system |
| OMA-4-006 | `omarchy-apply-hardware` must source `install/hardware/all.sh`. | bin/omarchy-apply-hardware |
| OMA-4-007 | The system install log must go to `/var/log/omarchy-install.log`. | bin/omarchy-apply-system |
| OMA-4-008 | The ISO must then run `omarchy finalize user --force --first-install` (`omarchy-provision-user`) as the install user. | bin/omarchy-provision-user |
| OMA-4-009 | With `--first-install`, finalization must mark all shipped migrations as applied. | bin/omarchy-provision-user |
| OMA-4-010 | Disk encryption (LUKS) must be the default. | manual/02-getting-started.md |
| OMA-4-011 | Secure Boot and TPM must be off for the install. | manual/02-getting-started.md |
| OMA-4-012 | Ctrl+C on the first installer screen must select deferred provisioning. | manual/51-unattended-installs.md |
| OMA-4-013 | Ctrl+C on the format confirmation must select an install without encryption. | manual/02-getting-started.md |
| OMA-4-014 | The ISO internals (partition layout, subvolume names other than `@` and `@factory`, autologin) are not determined from this repository. | (not in repository) |

### Config phase (`install/config/all.sh`)

| ID | Requirement | Source |
|---|---|---|
| OMA-4-015 | `theme-system.sh` must link the Yaru icon themes and write Chromium `initial_preferences` with `color_scheme` 0 and `require_eula` false. | install/config/theme-system.sh |
| OMA-4-016 | `browser-policy.sh` must create `/etc/chromium/policies/managed`. | install/config/browser-policy.sh |
| OMA-4-017 | `increase-lockout-limit.sh` must set `pam_faillock` in `system-auth` to `deny=10 unlock_time=120` and add `authsucc` for `sddm-autologin`. | install/config/increase-lockout-limit.sh |
| OMA-4-018 | `lockscreen-pam.sh` must run `omarchy-apply-lock`. | install/config/lockscreen-pam.sh |
| OMA-4-019 | `fix-powerprofilesctl-shebang.sh` must set the `powerprofilesctl` shebang to `#!/bin/python3`. | install/config/fix-powerprofilesctl-shebang.sh |
| OMA-4-020 | `ssh-command-path.sh` must add a `PATH` line with the mise shims and `~/.local/bin` to `/etc/security/pam_env.conf`. | install/config/ssh-command-path.sh |
| OMA-4-021 | `ssh-keepalive.sh` must write `/etc/ssh/ssh_config.d/20-omarchy-keepalive.conf` with `ServerAliveInterval 15`, `ServerAliveCountMax 3` and `ConnectTimeout 10`. | install/config/ssh-keepalive.sh |
| OMA-4-022 | `docker.sh` must not add the user to the `docker` group. | install/config/docker.sh |
| OMA-4-023 | `snapper.sh` must install the root config from the template, set `SNAPPER_CONFIGS="root"` and disable `snapper-timeline.timer`. | install/config/snapper.sh |
| OMA-4-024 | `snapper.sh` must enable `snapper-cleanup.timer` and `limine-snapper-sync.service`. | install/config/snapper.sh |
| OMA-4-025 | `enable-services.sh` must enable `cups`, `avahi-daemon`, `linux-modules-cleanup`, `docker.socket`, `systemd-resolved`, `NetworkManager`, `power-profiles-daemon`, `sddm` and `systemd-oomd`. | install/config/enable-services.sh |
| OMA-4-026 | `enable-services.sh` must mask `NetworkManager-wait-online`. | install/config/enable-services.sh |
| OMA-4-027 | `firewall.sh` must configure and enable `ufw` (see section 15). | install/config/firewall.sh |

### Login phase (`install/login/all.sh`)

| ID | Requirement | Source |
|---|---|---|
| OMA-4-028 | `sddm.sh` must remove the `pam_gnome_keyring` auth and password lines from `/etc/pam.d/sddm`. | install/login/sddm.sh |
| OMA-4-029 | The ISO must own the SDDM autologin setup. The details are not determined. | install/login/sddm.sh |

### Post-install phase (`install/post-install/all.sh`)

| ID | Requirement | Source |
|---|---|---|
| OMA-4-030 | `pacman.sh` must copy `default/pacman/pacman-${OMARCHY_MIRROR:-stable}.conf` to `/etc/pacman.conf` and install the mirror list. | install/post-install/pacman.sh |
| OMA-4-031 | `pacman.sh` must install the `cups-files.conf` override and source `install/hardware/pacman.sh` again. | install/post-install/pacman.sh |
| OMA-4-032 | `udev.sh` must reload the udev rules and trigger the `power_supply` subsystem. | install/post-install/udev.sh |
| OMA-4-033 | `localdb.sh` must run `updatedb --prune-bind-mounts=no --add-prunepaths=/.snapshots`. | install/post-install/localdb.sh |

### Deferred provisioning and owner setup

| ID | Requirement | Source |
|---|---|---|
| OMA-4-034 | `omarchy-provision-owner.service` must run on `tty1` when `/var/lib/omarchy/provisioning/pending` exists and `wipe-pending` does not exist. | install/provisioning/omarchy-provision-owner.service |
| OMA-4-035 | `omarchy-provision-owner.service` must run before `display-manager.service`. | bin/omarchy-provision-owner |
| OMA-4-036 | The owner form must ask for the keyboard layout, the account, the hostname and the timezone. | install/provisioning/setup-form.sh |
| OMA-4-037 | The keyboard list must show the English layouts first. | install/provisioning/setup-form.sh |
| OMA-4-038 | Owner provisioning must re-key the LUKS volume. | bin/omarchy-provision-owner |

### Unattended install

| ID | Requirement | Source |
|---|---|---|
| OMA-4-039 | The ISO must read a drive with the label `cidata` for an unattended install. | manual/51-unattended-installs.md |
| OMA-4-040 | The `cidata` drive can contain `user_configuration.json`, `user_credentials.json`, `authorized_keys`, `tailscale_authkey`, optional files and a `defer-provisioning` file. | manual/51-unattended-installs.md |

### Factory reset

| ID | Requirement | Source |
|---|---|---|
| OMA-4-041 | `omarchy-system-factory-reset` must replace the `@` subvolume with a clone of the `@factory` snapshot. | bin/omarchy-system-factory-reset |
| OMA-4-042 | Only ISO installs of v4 that have the `@factory` snapshot must allow a factory reset. | bin/omarchy-system-factory-reset |
| OMA-4-043 | `omarchy-system-factory-reset-finish.service` must run when `wipe-pending` exists, before `sysinit.target` and `home.mount`. | bin/omarchy-system-factory-reset; install/provisioning/omarchy-system-factory-reset-finish.service |

## 5. Packages

| ID | Requirement | Source |
|---|---|---|
| OMA-5-001 | The ISO must install every package in `install/omarchy-base.packages`. | install/omarchy-base.packages |
| OMA-5-002 | The packages in `install/omarchy-other.packages` must be available in the ISO offline mirror. Install scripts install them on condition. | install/omarchy-other.packages |
| OMA-5-003 | `omarchy-pkg-add` must use `pacman -S --needed` only. `omarchy-pkg-aur-add` must use the AUR. | bin/omarchy-pkg-add; bin/omarchy-pkg-aur-add |

### Base packages

| ID | Package | Preinstall (removable) | Source |
|---|---|---|---|
| OMA-5-004 | `aether` | yes | install/omarchy-base.packages |
| OMA-5-005 | `alsa-utils` | no | install/omarchy-base.packages |
| OMA-5-006 | `asdcontrol` | no | install/omarchy-base.packages |
| OMA-5-007 | `avahi` | no | install/omarchy-base.packages |
| OMA-5-008 | `bash-completion` | no | install/omarchy-base.packages |
| OMA-5-009 | `bat` | no | install/omarchy-base.packages |
| OMA-5-010 | `bluez` | no | install/omarchy-base.packages |
| OMA-5-011 | `bluez-tools` | no | install/omarchy-base.packages |
| OMA-5-012 | `bluez-utils` | no | install/omarchy-base.packages |
| OMA-5-013 | `bolt` | no | install/omarchy-base.packages |
| OMA-5-014 | `brightnessctl` | no | install/omarchy-base.packages |
| OMA-5-015 | `btop` | no | install/omarchy-base.packages |
| OMA-5-016 | `chromium` | no | install/omarchy-base.packages |
| OMA-5-017 | `clang` | no | install/omarchy-base.packages |
| OMA-5-018 | `cliamp` | yes | install/omarchy-base.packages |
| OMA-5-019 | `cups` | no | install/omarchy-base.packages |
| OMA-5-020 | `cups-filters` | no | install/omarchy-base.packages |
| OMA-5-021 | `cups-pk-helper` | no | install/omarchy-base.packages |
| OMA-5-022 | `ddcutil` | no | install/omarchy-base.packages |
| OMA-5-023 | `docker` | no | install/omarchy-base.packages |
| OMA-5-024 | `docker-buildx` | no | install/omarchy-base.packages |
| OMA-5-025 | `docker-compose` | no | install/omarchy-base.packages |
| OMA-5-026 | `dosfstools` | no | install/omarchy-base.packages |
| OMA-5-027 | `dotnet-runtime` | no | install/omarchy-base.packages |
| OMA-5-028 | `dua-cli` | no | install/omarchy-base.packages |
| OMA-5-029 | `evince` | no | install/omarchy-base.packages |
| OMA-5-030 | `exfatprogs` | no | install/omarchy-base.packages |
| OMA-5-031 | `expac` | no | install/omarchy-base.packages |
| OMA-5-032 | `eza` | no | install/omarchy-base.packages |
| OMA-5-033 | `fakeroot` | no | install/omarchy-base.packages |
| OMA-5-034 | `fastfetch` | no | install/omarchy-base.packages |
| OMA-5-035 | `fcitx5` | no | install/omarchy-base.packages |
| OMA-5-036 | `fcitx5-gtk` | no | install/omarchy-base.packages |
| OMA-5-037 | `fcitx5-qt` | no | install/omarchy-base.packages |
| OMA-5-038 | `fd` | no | install/omarchy-base.packages |
| OMA-5-039 | `ffmpegthumbnailer` | no | install/omarchy-base.packages |
| OMA-5-040 | `fontconfig` | no | install/omarchy-base.packages |
| OMA-5-041 | `foot` | no | install/omarchy-base.packages |
| OMA-5-042 | `fzf` | no | install/omarchy-base.packages |
| OMA-5-043 | `git` | no | install/omarchy-base.packages |
| OMA-5-044 | `gnome-keyring` | no | install/omarchy-base.packages |
| OMA-5-045 | `gnome-themes-extra` | no | install/omarchy-base.packages |
| OMA-5-046 | `grim` | no | install/omarchy-base.packages |
| OMA-5-047 | `gpu-screen-recorder` | no | install/omarchy-base.packages |
| OMA-5-048 | `gum` | no | install/omarchy-base.packages |
| OMA-5-049 | `gvfs-mtp` | no | install/omarchy-base.packages |
| OMA-5-050 | `gvfs-nfs` | no | install/omarchy-base.packages |
| OMA-5-051 | `gvfs-smb` | no | install/omarchy-base.packages |
| OMA-5-052 | `herdr` | no | install/omarchy-base.packages |
| OMA-5-053 | `hyprland` | no | install/omarchy-base.packages |
| OMA-5-054 | `hyprland-guiutils` | no | install/omarchy-base.packages |
| OMA-5-055 | `hyprland-preview-share-picker` | no | install/omarchy-base.packages |
| OMA-5-056 | `hyprpicker` | no | install/omarchy-base.packages |
| OMA-5-057 | `hyprsunset` | no | install/omarchy-base.packages |
| OMA-5-058 | `imagemagick` | no | install/omarchy-base.packages |
| OMA-5-059 | `imv` | no | install/omarchy-base.packages |
| OMA-5-060 | `inetutils` | no | install/omarchy-base.packages |
| OMA-5-061 | `inotify-tools` | no | install/omarchy-base.packages |
| OMA-5-062 | `inxi` | no | install/omarchy-base.packages |
| OMA-5-063 | `networkmanager` | no | install/omarchy-base.packages |
| OMA-5-064 | `jq` | no | install/omarchy-base.packages |
| OMA-5-065 | `kdenlive` | yes | install/omarchy-base.packages |
| OMA-5-066 | `kernel-modules-hook` | no | install/omarchy-base.packages |
| OMA-5-067 | `lazydocker` | yes | install/omarchy-base.packages |
| OMA-5-068 | `lazygit` | no | install/omarchy-base.packages |
| OMA-5-069 | `less` | no | install/omarchy-base.packages |
| OMA-5-070 | `libsecret` | no | install/omarchy-base.packages |
| OMA-5-071 | `libvips` | no | install/omarchy-base.packages |
| OMA-5-072 | `libyaml` | no | install/omarchy-base.packages |
| OMA-5-073 | `libreoffice-fresh` | yes | install/omarchy-base.packages |
| OMA-5-074 | `llvm` | no | install/omarchy-base.packages |
| OMA-5-075 | `localsend` | no | install/omarchy-base.packages |
| OMA-5-076 | `lua51` | no | install/omarchy-base.packages |
| OMA-5-077 | `luarocks` | no | install/omarchy-base.packages |
| OMA-5-078 | `man-db` | no | install/omarchy-base.packages |
| OMA-5-079 | `mariadb-libs` | no | install/omarchy-base.packages |
| OMA-5-080 | `mise-bin` | no | install/omarchy-base.packages |
| OMA-5-081 | `moonlight-qt` | yes | install/omarchy-base.packages |
| OMA-5-082 | `mpv` | no | install/omarchy-base.packages |
| OMA-5-083 | `mpv-mpris` | no | install/omarchy-base.packages |
| OMA-5-084 | `nautilus` | no | install/omarchy-base.packages |
| OMA-5-085 | `nautilus-python` | no | install/omarchy-base.packages |
| OMA-5-086 | `gnome-disk-utility` | no | install/omarchy-base.packages |
| OMA-5-087 | `noto-fonts` | no | install/omarchy-base.packages |
| OMA-5-088 | `noto-fonts-cjk` | no | install/omarchy-base.packages |
| OMA-5-089 | `noto-fonts-emoji` | no | install/omarchy-base.packages |
| OMA-5-090 | `nss-mdns` | no | install/omarchy-base.packages |
| OMA-5-091 | `nvim` | no | install/omarchy-base.packages |
| OMA-5-092 | `obs-studio` | yes | install/omarchy-base.packages |
| OMA-5-093 | `obsidian` | yes | install/omarchy-base.packages |
| OMA-5-094 | `omacalc` | yes | install/omarchy-base.packages |
| OMA-5-095 | `omacut` | yes | install/omarchy-base.packages |
| OMA-5-096 | `omawrite` | yes | install/omarchy-base.packages |
| OMA-5-097 | `omarchy-nvim` | no | install/omarchy-base.packages |
| OMA-5-098 | `pacman-contrib` | no | install/omarchy-base.packages |
| OMA-5-099 | `pamixer` | no | install/omarchy-base.packages |
| OMA-5-100 | `pinta` | yes | install/omarchy-base.packages |
| OMA-5-101 | `plocate` | no | install/omarchy-base.packages |
| OMA-5-102 | `plymouth` | no | install/omarchy-base.packages |
| OMA-5-103 | `postgresql-libs` | no | install/omarchy-base.packages |
| OMA-5-104 | `power-profiles-daemon` | no | install/omarchy-base.packages |
| OMA-5-105 | `python-gobject` | no | install/omarchy-base.packages |
| OMA-5-106 | `python-poetry-core` | no | install/omarchy-base.packages |
| OMA-5-107 | `ttfx` | no | install/omarchy-base.packages |
| OMA-5-108 | `qemu-user-static-binfmt` | no | install/omarchy-base.packages |
| OMA-5-109 | `qrencode` | no | install/omarchy-base.packages |
| OMA-5-110 | `qt6-imageformats` | no | install/omarchy-base.packages |
| OMA-5-111 | `quickshell` | no | install/omarchy-base.packages |
| OMA-5-112 | `ripgrep` | no | install/omarchy-base.packages |
| OMA-5-113 | `ruby` | no | install/omarchy-base.packages |
| OMA-5-114 | `tensaku` | no | install/omarchy-base.packages |
| OMA-5-115 | `sddm` | no | install/omarchy-base.packages |
| OMA-5-116 | `slurp` | no | install/omarchy-base.packages |
| OMA-5-117 | `socat` | no | install/omarchy-base.packages |
| OMA-5-118 | `starship` | no | install/omarchy-base.packages |
| OMA-5-119 | `sushi` | no | install/omarchy-base.packages |
| OMA-5-120 | `system-config-printer` | no | install/omarchy-base.packages |
| OMA-5-121 | `tesseract` | no | install/omarchy-base.packages |
| OMA-5-122 | `tesseract-data-eng` | no | install/omarchy-base.packages |
| OMA-5-123 | `tldr` | no | install/omarchy-base.packages |
| OMA-5-124 | `tree-sitter-cli` | no | install/omarchy-base.packages |
| OMA-5-125 | `tmux` | no | install/omarchy-base.packages |
| OMA-5-126 | `tobi-try` | no | install/omarchy-base.packages |
| OMA-5-127 | `ttf-ia-writer` | no | install/omarchy-base.packages |
| OMA-5-128 | `ttf-jetbrains-mono-nerd-basic` | no | install/omarchy-base.packages |
| OMA-5-129 | `tzupdate` | no | install/omarchy-base.packages |
| OMA-5-130 | `udiskie` | no | install/omarchy-base.packages |
| OMA-5-131 | `ufw` | no | install/omarchy-base.packages |
| OMA-5-132 | `ufw-docker` | no | install/omarchy-base.packages |
| OMA-5-133 | `unzip` | no | install/omarchy-base.packages |
| OMA-5-134 | `usage` | no | install/omarchy-base.packages |
| OMA-5-135 | `uwsm` | no | install/omarchy-base.packages |
| OMA-5-136 | `whois` | no | install/omarchy-base.packages |
| OMA-5-137 | `wireless-regdb` | no | install/omarchy-base.packages |
| OMA-5-138 | `wireplumber` | no | install/omarchy-base.packages |
| OMA-5-139 | `wl-clipboard` | no | install/omarchy-base.packages |
| OMA-5-140 | `wtype` | no | install/omarchy-base.packages |
| OMA-5-141 | `woff2-font-awesome` | no | install/omarchy-base.packages |
| OMA-5-142 | `xdg-desktop-portal-gtk` | no | install/omarchy-base.packages |
| OMA-5-143 | `xdg-desktop-portal-hyprland` | no | install/omarchy-base.packages |
| OMA-5-144 | `xdg-terminal-exec` | no | install/omarchy-base.packages |
| OMA-5-145 | `xournalpp` | yes | install/omarchy-base.packages |
| OMA-5-146 | `yaru-icon-theme` | no | install/omarchy-base.packages |
| OMA-5-147 | `yay` | no | install/omarchy-base.packages |
| OMA-5-148 | `yt-dlp` | no | install/omarchy-base.packages |
| OMA-5-149 | `zbar` | no | install/omarchy-base.packages |
| OMA-5-150 | `zoxide` | no | install/omarchy-base.packages |

### Other packages

| ID | Package | Install script | Source |
|---|---|---|---|
| OMA-5-151 | `autoconf-archive` | not determined (no install script in this repository) | install/omarchy-other.packages |
| OMA-5-152 | `asusctl` | install/hardware/asus-rog.sh | install/omarchy-other.packages |
| OMA-5-153 | `base` | install/user/chromium.sh | install/omarchy-other.packages |
| OMA-5-154 | `base-devel` | not determined (no install script in this repository) | install/omarchy-other.packages |
| OMA-5-155 | `broadcom-wl-dkms` | install/hardware/fix-bcm43xx.sh | install/omarchy-other.packages |
| OMA-5-156 | `btrfs-progs` | bin/omarchy-system-factory-reset; bin/omarchy-system-factory-reset-finish | install/omarchy-other.packages |
| OMA-5-157 | `dkms` | install/hardware/apple/fix-spi-keyboard.sh; install/hardware/fix-bcm43xx.sh | install/omarchy-other.packages |
| OMA-5-158 | `egl-wayland` | not determined (no install script in this repository) | install/omarchy-other.packages |
| OMA-5-159 | `gst-plugin-pipewire` | bin/omarchy-upgrade-to-quattro | install/omarchy-other.packages |
| OMA-5-160 | `gtk4-layer-shell` | not determined (no install script in this repository) | install/omarchy-other.packages |
| OMA-5-161 | `libpulse` | bin/omarchy-upgrade-to-quattro | install/omarchy-other.packages |
| OMA-5-162 | `intel-ipu7-camera` | install/hardware/intel/ipu7-camera.sh | install/omarchy-other.packages |
| OMA-5-163 | `intel-lpmd` | install/hardware/intel/lpmd.sh | install/omarchy-other.packages |
| OMA-5-164 | `intel-media-driver` | install/hardware/intel/video-acceleration.sh | install/omarchy-other.packages |
| OMA-5-165 | `libva-intel-driver` | install/hardware/intel/video-acceleration.sh | install/omarchy-other.packages |
| OMA-5-166 | `libva-nvidia-driver` | install/hardware/nvidia.sh | install/omarchy-other.packages |
| OMA-5-167 | `limine` | install/config/snapper.sh; install/hardware/apple/fix-t2.sh | install/omarchy-other.packages |
| OMA-5-168 | `limine-mkinitcpio-hook` | bin/omarchy-hibernation-setup | install/omarchy-other.packages |
| OMA-5-169 | `limine-snapper-sync` | install/config/snapper.sh | install/omarchy-other.packages |
| OMA-5-170 | `linux-firmware` | install/hardware/dell-xps13-ptl-speaker-firmware.sh; install/hardware/surface.sh | install/omarchy-other.packages |
| OMA-5-171 | `linux-omarchy` | not determined (no install script in this repository) | install/omarchy-other.packages |
| OMA-5-172 | `linux-omarchy-headers` | not determined (no install script in this repository) | install/omarchy-other.packages |
| OMA-5-173 | `macbook12-spi-driver-dkms` | install/hardware/apple/fix-spi-keyboard.sh | install/omarchy-other.packages |
| OMA-5-174 | `nvidia-580xx-dkms` | install/hardware/nvidia.sh | install/omarchy-other.packages |
| OMA-5-175 | `nvidia-dkms` | not determined (no install script in this repository) | install/omarchy-other.packages |
| OMA-5-176 | `nvidia-open-dkms` | install/hardware/nvidia.sh | install/omarchy-other.packages |
| OMA-5-177 | `nvidia-580xx-utils` | install/hardware/nvidia.sh | install/omarchy-other.packages |
| OMA-5-178 | `nvidia-utils` | install/hardware/nvidia.sh; install/hardware/vulkan.sh | install/omarchy-other.packages |
| OMA-5-179 | `lib32-nvidia-580xx-utils` | install/hardware/nvidia.sh | install/omarchy-other.packages |
| OMA-5-180 | `lib32-nvidia-utils` | install/hardware/nvidia.sh | install/omarchy-other.packages |
| OMA-5-181 | `pipewire` | bin/omarchy-audio-tuning; bin/omarchy-restart-audio | install/omarchy-other.packages |
| OMA-5-182 | `pipewire-alsa` | bin/omarchy-upgrade-to-quattro | install/omarchy-other.packages |
| OMA-5-183 | `pipewire-jack` | bin/omarchy-upgrade-to-quattro | install/omarchy-other.packages |
| OMA-5-184 | `pipewire-pulse` | bin/omarchy-restart-audio; bin/omarchy-upgrade-to-quattro | install/omarchy-other.packages |
| OMA-5-185 | `qt6-wayland` | not determined (no install script in this repository) | install/omarchy-other.packages |
| OMA-5-186 | `snapper` | install/config/all.sh; install/config/snapper.sh | install/omarchy-other.packages |
| OMA-5-187 | `sof-firmware` | install/hardware/all.sh; install/hardware/intel/sof-firmware.sh | install/omarchy-other.packages |
| OMA-5-188 | `thermald` | install/hardware/all.sh; install/hardware/intel/thermald.sh | install/omarchy-other.packages |
| OMA-5-189 | `webp-pixbuf-loader` | not determined (no install script in this repository) | install/omarchy-other.packages |
| OMA-5-190 | `yay-debug` | not determined (no install script in this repository) | install/omarchy-other.packages |
| OMA-5-191 | `tuxedo-drivers-nocompatcheck-dkms` | install/hardware/fix-tuxedo-backlight.sh | install/omarchy-other.packages |
| OMA-5-192 | `yt6801-dkms` | install/hardware/fix-yt6801-ethernet-adapter.sh | install/omarchy-other.packages |
| OMA-5-193 | `zram-generator` | not determined (no install script in this repository) | install/omarchy-other.packages |
| OMA-5-194 | `libvpl` | install/hardware/intel/video-acceleration.sh | install/omarchy-other.packages |
| OMA-5-195 | `vpl-gpu-rt` | install/hardware/intel/video-acceleration.sh | install/omarchy-other.packages |
| OMA-5-196 | `vulkan-intel` | install/hardware/vulkan.sh | install/omarchy-other.packages |
| OMA-5-197 | `vulkan-radeon` | install/hardware/vulkan.sh | install/omarchy-other.packages |
| OMA-5-198 | `vulkan-asahi` | install/hardware/vulkan.sh | install/omarchy-other.packages |
| OMA-5-199 | `linux-firmware-marvell` | install/hardware/surface.sh | install/omarchy-other.packages |
| OMA-5-200 | `dell-xps-touchpad-haptics` | install/hardware/all.sh; install/hardware/dell-xps-touchpad-haptics.sh | install/omarchy-other.packages |
| OMA-5-201 | `linux-firmware-cirrus-dx13260` | install/hardware/dell-xps13-ptl-speaker-firmware.sh | install/omarchy-other.packages |
| OMA-5-202 | `lsp-plugins-lv2` | install/hardware/speaker-tuning.sh | install/omarchy-other.packages |
| OMA-5-203 | `apple-bcm-firmware-fetcher` | install/hardware/apple/fix-t2.sh | install/omarchy-other.packages |
| OMA-5-204 | `apple-t2-audio-config` | install/hardware/apple/fix-t2.sh | install/omarchy-other.packages |
| OMA-5-205 | `linux-t2` | install/hardware/apple/fix-t2.sh | install/omarchy-other.packages |
| OMA-5-206 | `linux-t2-headers` | install/hardware/apple/fix-t2.sh | install/omarchy-other.packages |
| OMA-5-207 | `t2fanrd` | install/hardware/apple/fix-t2.sh | install/omarchy-other.packages |
| OMA-5-208 | `qmk-hid` | install/hardware/all.sh; install/hardware/framework/qmk-hid.sh | install/omarchy-other.packages |

## 6. System configuration

### Boot and bootloader

| ID | Requirement | Source |
|---|---|---|
| OMA-6-001 | The Limine entry tool must set `TARGET_OS_NAME` to `Omarchy`. | etc/limine-entry-tool.d/ |
| OMA-6-002 | The kernel command line must be `quiet splash loglevel=0 systemd.show_status=false rd.udev.log_level=0 vt.global_cursor_default=0 initramfs_async=0 systemd.tty.term.console=dumb`. | etc/limine-entry-tool.d/ |
| OMA-6-003 | The UKI name must be `omarchy`. `ENABLE_UKI` must be `yes`. | etc/limine-entry-tool.d/ |
| OMA-6-004 | `ENABLE_LIMINE_FALLBACK` and `FIND_BOOTLOADERS` must be `yes`. | etc/limine-entry-tool.d/ |
| OMA-6-005 | The boot order must be `linux-t2, linux-omarchy, linux-omarchy-*, *, *fallback, Snapshots`. | etc/limine-entry-tool.d/ |
| OMA-6-006 | `MAX_SNAPSHOT_ENTRIES` must be 6. `SNAPSHOT_FORMAT_CHOICE` must be 5. | etc/limine-entry-tool.d/ |
| OMA-6-007 | `limine.conf` must use the Tokyo Night colors, the branding `Omarchy Bootloader` and `default_entry` 2. | default/limine/limine.conf |
| OMA-6-008 | The default kernel must be `linux-omarchy`. | install/omarchy-other.packages |

### Initramfs

| ID | Requirement | Source |
|---|---|---|
| OMA-6-009 | The mkinitcpio hooks must be `base udev plymouth keyboard autodetect microcode modconf kms keymap consolefont block encrypt filesystems fsck btrfs-overlayfs`. | etc/mkinitcpio.conf.d/omarchy_hooks.conf |
| OMA-6-010 | The `kms` hook must be removed on machines with only an NVIDIA GPU. | install/hardware/nvidia.sh |
| OMA-6-011 | A separate drop-in must add `MODULES+=(thunderbolt)`. | etc/mkinitcpio.conf.d/thunderbolt_module.conf |
| OMA-6-012 | A vconsole drop-in must apply for Latin keyboard layouts. | etc/mkinitcpio.conf.d/omarchy_vconsole.conf |

### Boot splash

| ID | Requirement | Source |
|---|---|---|
| OMA-6-013 | `plymouthd.conf` must set `Theme=omarchy`. | etc/plymouth/plymouthd.conf |
| OMA-6-014 | `omarchy-plymouth-*` commands must manage the Plymouth theme (see section 11). | bin/omarchy-plymouth-* |

### Snapshots

| ID | Requirement | Source |
|---|---|---|
| OMA-6-015 | The Snapper root config must set `NUMBER_LIMIT=5`, `NUMBER_LIMIT_IMPORTANT=5` and `TIMELINE_CREATE=no`. | default/snapper/root |
| OMA-6-016 | `limine-snapper-sync` must add snapshot boot entries. | install/config/snapper.sh |
| OMA-6-017 | `plocate` and `localdb` must skip `/.snapshots`. | install/post-install/localdb.sh |
| OMA-6-018 | The update procedure must make a snapshot before the package upgrade. | bin/omarchy-update |

### Login manager

| ID | Requirement | Source |
|---|---|---|
| OMA-6-019 | SDDM must use the theme `omarchy`. | etc/sddm.conf.d/ |
| OMA-6-020 | SDDM must use `DisplayServer=wayland`. | etc/sddm.conf.d/ |
| OMA-6-021 | The SDDM compositor command must be `start-hyprland -- --config /usr/share/sddm/hyprland.lua`. | etc/sddm.conf.d/ |
| OMA-6-022 | The Wayland session `omarchy.desktop` must run `uwsm start -g -1 -e -D Hyprland hyprland.desktop`. | default/wayland-sessions/omarchy.desktop |

### System services and systemd settings

| ID | Requirement | Source |
|---|---|---|
| OMA-6-023 | `DefaultTimeoutStopSec` must be `5s`. | etc/systemd/system.conf.d/ |
| OMA-6-024 | The `NOFILE` limit must be `65536:524288` for system and user managers. | etc/systemd/ |
| OMA-6-025 | `user@.service` must have `TimeoutStopSec=5s`. | default/systemd/user@.service.d/faster-shutdown.conf |
| OMA-6-026 | logind must set `HandlePowerKey=ignore` and `InhibitDelayMaxSec=15`. | etc/systemd/logind.conf.d/ |
| OMA-6-027 | systemd-oomd must use a pressure limit of 50% for 20 s. | etc/systemd/oomd.conf.d/ |
| OMA-6-028 | The user `app.slice` must use oomd kill on memory pressure and swap. | default/systemd/user/app.slice.d/10-oomd.conf |
| OMA-6-029 | zram must use `size=ram`, `zstd` compression and priority 100. | default/systemd/zram-generator.conf.d/ |
| OMA-6-030 | zswap must be off through tmpfiles. | etc/tmpfiles.d/ |
| OMA-6-031 | `docker.service` must have `DefaultDependencies=no`. | etc/systemd/system/docker.service.d/ |
| OMA-6-032 | The `plocate-updatedb` service must have `ConditionACPower=true`. | etc/systemd/; default/systemd/system/plocate-updatedb.service.d/10-omarchy.conf |
| OMA-6-033 | `cups-browsed` must run with a hardening drop-in and a sysusers entry. | etc/systemd/; etc/sysusers.d/ |
| OMA-6-034 | `supergfxd` must have a delay-start drop-in with `sleep 5`. | default/systemd/system/supergfxd.service.d/delay-start.conf |
| OMA-6-035 | The system-sleep script `unmount-fuse` must unmount FUSE mounts before sleep. | default/systemd/system-sleep/unmount-fuse |
| OMA-6-036 | The system-sleep scripts `force-igpu` and `keyboard-backlight` must be installed only on hardware that needs them. | docs/file-layout.md |

### Kernel settings (sysctl and modprobe)

| ID | Setting | Value | Source |
|---|---|---|---|
| OMA-6-037 | `fs.inotify.max_user_watches` | 524288 | etc/sysctl.d/ |
| OMA-6-038 | `net.ipv4.tcp_mtu_probing` | 1 | etc/sysctl.d/ |
| OMA-6-039 | `vm.swappiness` | 150 | etc/sysctl.d/ |
| OMA-6-040 | `vm.vfs_cache_pressure` | 50 | etc/sysctl.d/ |
| OMA-6-041 | `vm.page-cluster` | 0 | etc/sysctl.d/ |
| OMA-6-042 | `vm.watermark_boost_factor` | 0 | etc/sysctl.d/ |
| OMA-6-043 | `vm.watermark_scale_factor` | 125 | etc/sysctl.d/ |
| OMA-6-044 | `vm.dirty_background_bytes` | 64 MiB | etc/sysctl.d/ |
| OMA-6-045 | `vm.dirty_bytes` | 256 MiB | etc/sysctl.d/ |
| OMA-6-046 | `vm.dirty_writeback_centisecs` | 1500 | etc/sysctl.d/ |
| OMA-6-047 | `usbcore autosuspend` | -1 | etc/modprobe.d/ |

### PAM

| ID | Requirement | Source |
|---|---|---|
| OMA-6-048 | `pam_faillock` must use `deny=10` and `unlock_time=120`. | install/config/increase-lockout-limit.sh; etc/security/faillock.conf |
| OMA-6-049 | The lock screen must use the PAM services `omarchy-lock-password` and `omarchy-lock-fingerprint`. | bin/omarchy-apply-lock |
| OMA-6-050 | The SDDM PAM stack must not unlock GNOME Keyring. | install/login/sddm.sh |
| OMA-6-051 | `pam_env.conf` must set a `PATH` for SSH commands. | install/config/ssh-command-path.sh |
| OMA-6-052 | Fingerprint and FIDO2 PAM changes are in section 15. | bin/omarchy-setup-security-fingerprint; bin/omarchy-setup-security-fido2 |

### Firewall

| ID | Requirement | Source |
|---|---|---|
| OMA-6-053 | The firewall rules are in section 15. | install/config/firewall.sh |

### Networking

| ID | Requirement | Source |
|---|---|---|
| OMA-6-054 | NetworkManager must manage the network. | install/config/enable-services.sh |
| OMA-6-055 | `iwd`, `systemd-networkd` and its sockets must be off. `systemd-networkd-wait-online` must be masked. | install/hardware/network.sh |
| OMA-6-056 | The stock `20-*.network` files must move to a backup location. | install/hardware/network.sh |
| OMA-6-057 | NetworkManager must set `wifi.powersave=2` (off). | etc/NetworkManager/conf.d/ |
| OMA-6-058 | systemd-resolved must set `LLMNR=no`, `MulticastDNS=no` and `DNSStubListenerExtra=172.17.0.1`. | etc/systemd/resolved.conf.d/ |
| OMA-6-059 | The `hosts` line in `nsswitch.conf` must be `mymachines mdns_minimal [NOTFOUND=return] resolve files myhostname dns`. | etc/nsswitch.conf |
| OMA-6-060 | `WIRELESS_REGDOM` must come from the timezone and go into `/etc/conf.d/wireless-regdom`. | install/hardware/set-wireless-regdom.sh |
| OMA-6-061 | `omarchy-dns-*` must switch the DNS between Cloudflare, Google and DHCP without a password. | etc/sudoers.d/omarchy-dns |
| OMA-6-062 | Docker must use `json-file` logs (10m, 5 files), DNS `172.17.0.1` and `bip 172.17.0.1/16`. | etc/docker/daemon.json |
| OMA-6-063 | SSH clients must use keepalive settings (see section 4). | install/config/ssh-keepalive.sh |

### Audio

| ID | Requirement | Source |
|---|---|---|
| OMA-6-064 | PipeWire with `pipewire-pulse`, `pipewire-alsa`, `pipewire-jack` and WirePlumber must supply audio. | install/omarchy-other.packages; install/omarchy-base.packages |
| OMA-6-065 | First-run must run `omarchy-audio-tuning on`. | install/user/first-run/ |
| OMA-6-066 | The speaker tuning must use the user unit `omarchy-speaker-tuning.service` with `pipewire -c omarchy-speaker-tuning.conf`. | default/systemd/user/omarchy-speaker-tuning.service |
| OMA-6-067 | WirePlumber must use the `alsa-soft-mixer` config on hardware that needs it. | default/wireplumber; install/user/hardware |

### Power

| ID | Requirement | Source |
|---|---|---|
| OMA-6-068 | `power-profiles-daemon` must be on. `omarchy-powerprofiles-init` must run at session start. | install/config/enable-services.sh; default/hypr/autostart.lua |
| OMA-6-069 | The battery service must warn at 10% and run the `battery-low` hook. | shell/plugins/services/battery |
| OMA-6-070 | The power key must open the system menu. logind must ignore it. | default/hypr/bindings/utilities.lua; etc/systemd/logind.conf.d/ |
| OMA-6-071 | `omarchy-hibernation-setup` and `omarchy-hibernation-remove` must add and remove hibernation. | bin/omarchy-hibernation-* |

### Printing

| ID | Requirement | Source |
|---|---|---|
| OMA-6-072 | CUPS, `cups-filters`, `cups-pk-helper` and `system-config-printer` must be installed and `cups` must be on. | install/omarchy-base.packages |
| OMA-6-073 | `cups-browsed` must use Driverless and must not add remote queues. | etc/cups/cups-browsed.conf |
| OMA-6-074 | Avahi and `nss-mdns` must supply printer discovery. | install/config/enable-services.sh; etc/nsswitch.conf |
| OMA-6-075 | The `print-applet` autostart entry must be hidden. | config/autostart/print-applet.desktop |

### Fonts

| ID | Requirement | Source |
|---|---|---|
| OMA-6-076 | The fontconfig default `sans-serif` must be `Liberation Sans`. `serif` must be `Liberation Serif`. `monospace` must be `JetBrainsMono Nerd Font`. | default/fontconfig/ |
| OMA-6-077 | Fontconfig must have rules for `Noto Naskh Arabic` and Urdu. | default/fontconfig/ |
| OMA-6-078 | The Omarchy icon font must be `default/fonts/omarchy/omarchy.ttf`. | default/fonts/omarchy/ |
| OMA-6-079 | `omarchy-font-set` must change the monospace font and run the `font-set` hook. | bin/omarchy-font-set |

### Locale and time

| ID | Requirement | Source |
|---|---|---|
| OMA-6-080 | The timezone must come from the owner form or from `tzupdate`. | install/provisioning/setup-form.sh |
| OMA-6-081 | `timedatectl set-timezone` must run without a password through sudoers. | etc/sudoers.d/tzupdate |
| OMA-6-082 | The locale setup is not determined from this repository. The ISO sets it. | (not in repository) |

### Input methods and keyboard

| ID | Requirement | Source |
|---|---|---|
| OMA-6-083 | `INPUT_METHOD`, `QT_IM_MODULE`, `XMODIFIERS` and `SDL_IM_MODULE` must be `fcitx`. | default/environment.d/ |
| OMA-6-084 | The user unit `omarchy-fcitx5` must run `fcitx5 --disable notificationitem` with `Restart=always`. | default/systemd/user/omarchy-fcitx5.service |
| OMA-6-085 | The fcitx5 XDG autostart entry must be hidden. | config/autostart/org.fcitx.Fcitx5.desktop |
| OMA-6-086 | `~/.XCompose` must include `/usr/share/omarchy/default/xcompose`. | install/user/xcompose.sh |
| OMA-6-087 | `<Multi_key> <space> <n>` must type the user name. `<Multi_key> <space> <e>` must type the email. | install/user/xcompose.sh |
| OMA-6-088 | `hid_apple` must use `fnmode=2`. | install/hardware/fix-fkeys.sh |

### Other /etc files

| ID | Requirement | Source |
|---|---|---|
| OMA-6-089 | `dirmngr` must use the keyservers in `etc/gnupg`. | etc/gnupg/ |
| OMA-6-090 | Kitty must allow socket-only remote control. | etc/xdg/kitty/kitty.conf |
| OMA-6-091 | Fastfetch must use `etc/fastfetch/config.jsonc`. | etc/fastfetch/config.jsonc |
| OMA-6-092 | mise must have a `cursor-agent` alias. | etc/mise/ |
| OMA-6-093 | The libalpm hooks must be `00-omarchy-update-guard`, `10-hyprland-reload-pause` and `90-hyprland-reload-resume`. | default/libalpm/ |

## 7. User environment

### Config seed (`config/`)

| ID | Seed entry | Target | Source |
|---|---|---|---|
| OMA-7-001 | `alacritty` | `~/.config/alacritty` | config/alacritty |
| OMA-7-002 | `autostart` | `~/.config/autostart` | config/autostart |
| OMA-7-003 | `btop` | `~/.config/btop` | config/btop |
| OMA-7-004 | `chromium` | `~/.config/chromium` | config/chromium |
| OMA-7-005 | `chromium-flags.conf` | `~/.config/chromium-flags.conf` | config/chromium-flags.conf |
| OMA-7-006 | `fcitx5` | `~/.config/fcitx5` | config/fcitx5 |
| OMA-7-007 | `foot` | `~/.config/foot` | config/foot |
| OMA-7-008 | `ghostty` | `~/.config/ghostty` | config/ghostty |
| OMA-7-009 | `git` | `~/.config/git` | config/git |
| OMA-7-010 | `herdr` | `~/.config/herdr` | config/herdr |
| OMA-7-011 | `hypr` | `~/.config/hypr` | config/hypr |
| OMA-7-012 | `hyprland-mimeapps.list` | `~/.config/hyprland-mimeapps.list` | config/hyprland-mimeapps.list |
| OMA-7-013 | `hyprland-preview-share-picker` | `~/.config/hyprland-preview-share-picker` | config/hyprland-preview-share-picker |
| OMA-7-014 | `imv` | `~/.config/imv` | config/imv |
| OMA-7-015 | `kitty` | `~/.config/kitty` | config/kitty |
| OMA-7-016 | `lazygit` | `~/.config/lazygit` | config/lazygit |
| OMA-7-017 | `obsidian` | `~/.config/obsidian` | config/obsidian |
| OMA-7-018 | `omarchy` | `~/.config/omarchy` | config/omarchy |
| OMA-7-019 | `opencode` | `~/.config/opencode` | config/opencode |
| OMA-7-020 | `starship.toml` | `~/.config/starship.toml` | config/starship.toml |
| OMA-7-021 | `tmux` | `~/.config/tmux` | config/tmux |
| OMA-7-022 | `wireplumber` | `~/.config/wireplumber` | config/wireplumber |
| OMA-7-023 | `xournalpp` | `~/.config/xournalpp` | config/xournalpp |

| ID | Requirement | Source |
|---|---|---|
| OMA-7-024 | The seed must include the desktop entries in `applications/` in `~/.local/share/applications/`. | docs/file-layout.md |
| OMA-7-025 | The seed must include `~/.local/state/omarchy/toggles/hypr/flags.lua`. | docs/file-layout.md |
| OMA-7-026 | The seed must include the Nautilus Python extensions `localsend.py` and `transcode.py`. | default/nautilus-python/ |
| OMA-7-027 | The seed must include `~/.local/state/tensaku/state.toml`. | default/tensaku/ |
| OMA-7-028 | The seed must include `~/.config/omarchy/branding/about.txt` and `screensaver.txt`. | docs/file-layout.md |
| OMA-7-029 | The autostart entries for fcitx5, `print-applet` and `limine-snapper-notify` must be hidden. | config/autostart/ |

### Finalization (`omarchy-provision-user`)

| ID | Requirement | Source |
|---|---|---|
| OMA-7-030 | `omarchy-provision-user` must not run as root. | bin/omarchy-provision-user |
| OMA-7-031 | It must link the agent skills `omarchy` and `diagnose-crash` into `~/.agents`, `~/.claude`, `~/.codex`, `~/.pi/agent` and `~/.hermes/skills`. | bin/omarchy-provision-user |
| OMA-7-032 | It must also link the skills into each existing `~/.hermes/profiles/*/skills`. | bin/omarchy-provision-user |
| OMA-7-033 | It must set the XDG dirs `TEMPLATES`, `PUBLICSHARE` and `DESKTOP` to `$HOME` and remove those directories. | bin/omarchy-provision-user |
| OMA-7-034 | It must add GTK 3 bookmarks for Downloads, Projects, Pictures and Videos. | bin/omarchy-provision-user |
| OMA-7-035 | It must set `chromium.desktop` as the default browser and `HEY.desktop` for `mailto`. | bin/omarchy-provision-user |
| OMA-7-036 | It must run `omarchy-refresh-applications` and source `install/user/all.sh`. | bin/omarchy-provision-user |
| OMA-7-037 | It must write the marker `~/.local/state/omarchy/done/finalize-user`. | bin/omarchy-provision-user |

### User install scripts (`install/user/all.sh`)

| ID | Requirement | Source |
|---|---|---|
| OMA-7-038 | `theme.sh` must set the theme `Tokyo Night` when `theme.name` is empty, run `omarchy-theme-set-pi --activate` and link the btop theme. | install/user/theme.sh |
| OMA-7-039 | `chromium.sh` must install the Chromium extensions copy-url and yt-dlp. | install/user/chromium.sh |
| OMA-7-040 | `git.sh` must set `user.name` and `user.email` from `OMARCHY_USER_NAME` and `OMARCHY_USER_EMAIL`. | install/user/git.sh |
| OMA-7-041 | `xcompose.sh` must write `~/.XCompose`. | install/user/xcompose.sh |
| OMA-7-042 | `mise-work.sh` must create `~/Work` and `~/Work/tries`. | install/user/mise-work.sh |
| OMA-7-043 | `mise-work.sh` must install Node.js from the bundled archive when offline, or run `mise use -g node@latest`. | install/user/mise-work.sh |
| OMA-7-044 | `default-keyring.sh` must create `Default_keyring.keyring` with `lock-on-idle=false`. | install/user/default-keyring.sh |
| OMA-7-045 | `mise.sh` must set `upgrade.auto_prune` to false. | install/user/mise.sh |
| OMA-7-046 | `mise.sh` must install codex, claude, crush, gemini, gh, copilot, opencode, playwright, pi, omp, grok, cursor-agent, ghui, hunk and muse through `omarchy-mise-install`. | install/user/mise.sh |
| OMA-7-047 | The hardware leaves of `install/user/` are in section 14. | install/user/hardware/ |

### First-run (`omarchy-provision-first-run`)

| ID | Requirement | Source |
|---|---|---|
| OMA-7-048 | Hyprland autostart must run `omarchy-provision-first-run`. | bin/omarchy-provision-first-run; install/user/first-run/ |
| OMA-7-049 | First-run must accept `--force`. | bin/omarchy-provision-first-run; install/user/first-run/ |
| OMA-7-050 | First-run must write the marker `~/.local/state/omarchy/done/first-run-user` only after all steps succeed. | bin/omarchy-provision-first-run; install/user/first-run/ |
| OMA-7-051 | If a step fails, first-run must run again at the next login. | bin/omarchy-provision-first-run; install/user/first-run/ |
| OMA-7-052 | First-run must write its log to `~/.local/state/omarchy/first-run.log`. | bin/omarchy-provision-first-run; install/user/first-run/ |
| OMA-7-053 | First-run must run `omarchy-provision-user`. | bin/omarchy-provision-first-run; install/user/first-run/ |
| OMA-7-054 | First-run must install the post-update hooks `install-voxtype.hook`, `setup-fingerprint.hook` and `setup-agent.hook`. | bin/omarchy-provision-first-run; install/user/first-run/ |
| OMA-7-055 | First-run must enable the user units in the table in this section. | bin/omarchy-provision-first-run; install/user/first-run/ |
| OMA-7-056 | First-run must set the GNOME theme `Adwaita-dark`, `prefer-dark` and the icon theme `Yaru-blue`. | bin/omarchy-provision-first-run; install/user/first-run/ |
| OMA-7-057 | First-run must set GTK primary paste to true. | bin/omarchy-provision-first-run; install/user/first-run/ |
| OMA-7-058 | First-run must run `omarchy-audio-tuning on`. | bin/omarchy-provision-first-run; install/user/first-run/ |
| OMA-7-059 | First-run must wait for the notification server. | bin/omarchy-provision-first-run; install/user/first-run/ |
| OMA-7-060 | First-run must show the notification "Super + K for cheatsheet. Super + Space for Omarchy Menu.". | bin/omarchy-provision-first-run; install/user/first-run/ |
| OMA-7-061 | A click on the welcome notification must open `omarchy-menu-keybindings`. | bin/omarchy-provision-first-run; install/user/first-run/ |
| OMA-7-062 | If the system is offline, first-run must show a "Setup Wi-Fi" notification that opens the network panel. | bin/omarchy-provision-first-run; install/user/first-run/ |
| OMA-7-063 | First-run must show an "Update System" notification. | bin/omarchy-provision-first-run; install/user/first-run/ |

### Migrations

| ID | Requirement | Source |
|---|---|---|
| OMA-7-064 | Each migration must be a shell script in `migrations/` with a Unix timestamp name. | migrations/ |
| OMA-7-065 | v4.0.6 must ship 120 migrations, from `1778623107.sh` to `1792334754.sh`. | migrations/ |
| OMA-7-066 | `omarchy-migrate` must run each pending migration one time per user. | bin/omarchy-migrate |
| OMA-7-067 | The migration state must be in `~/.local/state/omarchy/migrations`. | bin/omarchy-migrate; docs/migrations.md |
| OMA-7-068 | `omarchy-migrate --pending` must list the pending migrations. | bin/omarchy-migrate |
| OMA-7-069 | The user unit `omarchy-migrate-notify` must tell the user about pending migrations at login. | default/systemd/user/omarchy-migrate-notify.service |

### State directories

| ID | Path (under `~/.local/state/omarchy/`) | Function | Source |
|---|---|---|---|
| OMA-7-070 | `current/theme` | Active rendered theme. | bin/omarchy-theme-set |
| OMA-7-071 | `current/theme.name` | Active theme name. | bin/omarchy-theme-set |
| OMA-7-072 | `current/background` | Symlink to the active background. | bin/omarchy-theme-bg-set |
| OMA-7-073 | `current/next-theme` | Staging directory for a theme change. | bin/omarchy-theme-set |
| OMA-7-074 | `migrations/` | Applied migration markers. | bin/omarchy-migrate |
| OMA-7-075 | `done/` | Setup step markers. | bin/omarchy-provision-user |
| OMA-7-076 | `toggles/` | Feature flags (`bar-off`, `crash-capture-off`, `suspend-off`, `hypr/*.lua`). | bin/omarchy-toggle-* |
| OMA-7-077 | `indicators/stay-awake` | Stay-awake indicator state. | bin/omarchy-update |
| OMA-7-078 | `defaults/editor` | Default editor (default `nvim`). | bin/omarchy-default-editor |
| OMA-7-079 | `notifications/` | Notification history. | shell/plugins/notifications |
| OMA-7-080 | `settings/weather.json` | Weather settings. | shell/plugins/panels/weather |
| OMA-7-081 | `clipboard-history.json` | Clipboard history. | shell/plugins/clipboard |
| OMA-7-082 | `agents/usage` | AI agent usage data. | shell/plugins/agents |
| OMA-7-083 | `workspace-layouts` | Per-workspace layouts. | default/hypr/workspace-layouts.lua |
| OMA-7-084 | `preinstalls-removed` | Flag that disables the preinstall bindings. | bin/omarchy-remove-preinstalls |
| OMA-7-085 | `reboot-required`, `restart-*-required` | Markers that the update restart step reads. | bin/omarchy-update-restart |
| OMA-7-086 | `first-run.log` | First-run log. | bin/omarchy-provision-first-run |

### User systemd units

| ID | Unit | Function | Enabled by first-run | Source |
|---|---|---|---|---|
| OMA-7-087 | `bt-agent.service` | Bluetooth pairing agent with `NoInputNoOutput`. Runs only if `/sys/class/bluetooth` exists and `bluetooth.service` is active. | yes | default/systemd/user/bt-agent.service |
| OMA-7-088 | `omarchy-recover-internal-monitor.service` | Turns the internal monitor on again if `internal-monitor-disable.lua` exists. Runs before `graphical-session-pre.target`. | yes | default/systemd/user/ |
| OMA-7-089 | `omarchy-sleep-lock.service` | Runs `omarchy-system-sleep-monitor` to lock before sleep. | yes | default/systemd/user/ |
| OMA-7-090 | `omarchy-migrate-notify.service` | Oneshot after `graphical-session.target`. | yes | default/systemd/user/ |
| OMA-7-091 | `omarchy-fcitx5.service` | Runs fcitx5. `ConditionEnvironment=WAYLAND_DISPLAY`. | yes | default/systemd/user/ |
| OMA-7-092 | `omarchy-crash-watch.service` | Captures crashes. Off if the toggle `crash-capture-off` exists. | yes | default/systemd/user/ |
| OMA-7-093 | `omarchy-speaker-tuning.service` | PipeWire speaker tuning filter. | no | default/systemd/user/ |
| OMA-7-094 | `omarchy-tailscale-receive.service` | Receives Tailscale Taildrop files. | no | default/systemd/user/ |

### Shell (Bash) environment

| ID | Requirement | Source |
|---|---|---|
| OMA-7-095 | `~/.bashrc` must source the Omarchy aliases, functions, init and envs from `default/bash`. | default/bash/; default/bashrc |
| OMA-7-096 | The init must activate mise, starship, zoxide, try and fzf. | default/bash/init |
| OMA-7-097 | The functions must cover compression, drives, herdr, rsync, SSH port forward, SSH reconnect, tmux and git worktrees. | default/bash/fns/ |
| OMA-7-098 | `ls` must be an alias for `eza`. `cd` must use zoxide. | default/bash/aliases |

### Default applications and environment

| ID | Requirement | Source |
|---|---|---|
| OMA-7-099 | The default terminal must be foot through `xdg-terminal-exec`. | default/xdg-terminal-exec/ |
| OMA-7-100 | `TERMINAL` must be `xdg-terminal-exec`. `EDITOR` must be `omarchy-launch-editor --inline`. | default/uwsm/default |
| OMA-7-101 | The uwsm environment must not export `BROWSER`. | default/uwsm/default |
| OMA-7-102 | `OMARCHY_SCREENSHOT_DIR` and `OMARCHY_SCREENRECORD_DIR` must be optional. | default/uwsm/default |
| OMA-7-103 | The uwsm `env.d` must source the bootstrap and run `mise activate bash --shims`. | default/uwsm/env.d |

| ID | MIME type | Default application | Source |
|---|---|---|---|
| OMA-7-104 | `inode/directory` | Nautilus | default/applications/mimeapps.list |
| OMA-7-105 | images | imv | default/applications/mimeapps.list |
| OMA-7-106 | `application/pdf` | Evince | default/applications/mimeapps.list |
| OMA-7-107 | `x-scheme-handler/http`, `https` | Chromium (user list: `omarchy-browser.desktop`) | default/applications/mimeapps.list; config/hyprland-mimeapps.list |
| OMA-7-108 | `x-scheme-handler/mailto` | HEY | default/applications/mimeapps.list |
| OMA-7-109 | video | mpv | default/applications/mimeapps.list |
| OMA-7-110 | text | Neovim | default/applications/mimeapps.list |

### Hooks

| ID | Hook | Event | Source |
|---|---|---|---|
| OMA-7-111 | `battery-low` | Battery reaches the low threshold. | config/omarchy/hooks/battery-low.d |
| OMA-7-112 | `font-set` | The font changes. | config/omarchy/hooks/font-set.d |
| OMA-7-113 | `post-boot` | Two seconds after session start. | config/omarchy/hooks/post-boot.d; default/hypr/autostart.lua |
| OMA-7-114 | `post-update` | After `omarchy-update`. | config/omarchy/hooks/post-update.d |
| OMA-7-115 | `pre-refresh-pacman` | Before the pacman config refresh. | config/omarchy/hooks/pre-refresh-pacman.d |
| OMA-7-116 | `theme-set` | After a theme change. | config/omarchy/hooks/theme-set.d |

| ID | Requirement | Source |
|---|---|---|
| OMA-7-117 | `omarchy-hook <name>` must run `~/.config/omarchy/hooks/<name>` and each file in `<name>.d/`. | bin/omarchy-hook |

## 8. Desktop shell

### Shell process

| ID | Requirement | Source |
|---|---|---|
| OMA-8-001 | One Quickshell instance must supply the bar, launcher, menu, notifications, OSD, lock, idle and panels. | shell/shell.qml; shell/README.md |
| OMA-8-002 | `omarchy-launch-shell` must run `quickshell -n -p $OMARCHY_PATH/shell` and log through `systemd-cat`. | bin/omarchy-launch-shell |
| OMA-8-003 | Omarchy v4 must not use Waybar, Walker, Mako, hypridle, hyprlock or swayosd. | shell/; install/omarchy-base.packages |
| OMA-8-004 | `omarchy-shell` must call the shell IPC methods `ping`, `summon`, `hide`, `toggle`, `call`, `rescanPlugins`, `reloadConfig`, `toggleBarTransparency`, `setPluginEnabled`, `enablePlugin`, `moveBarWidget`, `setBarWidget` and `listPlugins`. | shell/shell.qml; bin/omarchy-shell |
| OMA-8-005 | The shell must read theme tokens from `colors.toml` and `shell.toml` of the current theme. | docs/omarchy-shell.md |
| OMA-8-006 | The user config must be `~/.config/omarchy/shell.json`. | config/omarchy/shell.json |

### Plugins

| ID | Plugin | Kind | Function | Source |
|---|---|---|---|---|
| OMA-8-007 | `omarchy.bar` | bar | Top bar. | shell/plugins/bar |
| OMA-8-008 | `omarchy.menu` | menu, bar-widget | Omarchy menu and launcher. | shell/plugins/menu |
| OMA-8-009 | `omarchy.notifications` | service | Notification server. History limit 10. Do-not-disturb mode. | shell/plugins/notifications |
| OMA-8-010 | `omarchy.osd` | panel | On-screen display. | shell/plugins/osd |
| OMA-8-011 | `omarchy.lock` | service | Lock screen with PAM password and fingerprint. | shell/plugins/lock |
| OMA-8-012 | `omarchy.polkit` | service | Polkit authentication agent. | shell/plugins/polkit |
| OMA-8-013 | `omarchy.background` | service | Desktop background with transitions. | shell/plugins/background |
| OMA-8-014 | `omarchy.image-picker` | overlay | Background and image picker. | shell/plugins/image-picker |
| OMA-8-015 | `omarchy.emojis` | overlay | Emoji picker. | shell/plugins/emojis |
| OMA-8-016 | `omarchy.clipboard` | overlay | Clipboard history manager. Uses `wl-paste --watch`. | shell/plugins/clipboard |
| OMA-8-017 | `omarchy.reminders` | overlay | Reminders. | shell/plugins/reminders |
| OMA-8-018 | `omarchy.agents` | bar-widget, panel | AI agent usage. | shell/plugins/agents |
| OMA-8-019 | `omarchy.audio` | bar-widget, panel | Audio output and input. | shell/plugins/panels/audio |
| OMA-8-020 | `omarchy.bluetooth` | bar-widget, panel | Bluetooth devices. | shell/plugins/panels/bluetooth |
| OMA-8-021 | `omarchy.clock` | bar-widget, panel | Clock and calendar. | shell/plugins/panels/clock |
| OMA-8-022 | `omarchy.monitor` | bar-widget, panel | Display settings. | shell/plugins/panels/monitor |
| OMA-8-023 | `omarchy.network` | bar-widget, panel | Network and Wi-Fi. | shell/plugins/panels/network |
| OMA-8-024 | `omarchy.power` | bar-widget, panel | Power profiles and battery. | shell/plugins/panels/power |
| OMA-8-025 | `omarchy.tailscale` | bar-widget, panel | Tailscale status. | shell/plugins/panels/tailscale |
| OMA-8-026 | `omarchy.dropbox` | bar-widget, panel | Dropbox status. | shell/plugins/panels/dropbox |
| OMA-8-027 | `omarchy.weather` | bar-widget, panel | Weather. | shell/plugins/panels/weather |
| OMA-8-028 | `omarchy.speedtest` | panel | Network speed test. | shell/plugins/panels/speedtest |
| OMA-8-029 | `omarchy.disk-speedtest` | panel | Disk speed test. | shell/plugins/panels/disk-speedtest |
| OMA-8-030 | `omarchy.wifiqr` | panel | Wi-Fi QR code. | shell/plugins/panels/wifiqr |
| OMA-8-031 | `omarchy.dev-gallery` | panel | Developer component gallery. | shell/plugins/dev-gallery |
| OMA-8-032 | `omarchy.media` | service, bar-widget | MPRIS media control. | shell/plugins/services/media |
| OMA-8-033 | `omarchy.battery` | service | Battery state. Low threshold 10%. | shell/plugins/services/battery |
| OMA-8-034 | `omarchy.idle` | service | Idle timers for screensaver and lock. | shell/plugins/services/idle |
| OMA-8-035 | `omarchy.nightlight` | service | Night light at 4000 K through hyprsunset. | shell/plugins/services/nightlight |

### Bar

| ID | Requirement | Source |
|---|---|---|
| OMA-8-036 | The bar must be at the top. | config/omarchy/shell.json |
| OMA-8-037 | The bar center anchor must be `omarchy.clock`. | config/omarchy/shell.json |
| OMA-8-038 | The left area must show `menu` and `workspaces`. | config/omarchy/shell.json |
| OMA-8-039 | The center area must show `indicators`, `clock`, `keyboard-layout`, `weather` and `system-update`. | config/omarchy/shell.json |
| OMA-8-040 | The right area must show `tray`, `agents`, `bluetooth`, `network`, `audio`, `monitor` and `power`. | config/omarchy/shell.json |
| OMA-8-041 | The clock format must be `dddd HH:mm`. | config/omarchy/shell.json |
| OMA-8-042 | The bar-only widgets must be `active-window`, `indicators`, `keyboard-layout`, `microphone`, `spacer`, `system-update`, `tray` and `workspaces`. | shell/plugins/bar/widgets/ |
| OMA-8-043 | The indicators must be Dictation, Dnd, NightLight, Reminder, ScreenRecording and StayAwake. | shell/plugins/bar/indicators/ |
| OMA-8-044 | The `system-update` widget must check for updates at startup and every 6 hours. | shell/plugins/bar/widgets/SystemUpdate.qml |
| OMA-8-045 | The bar must support custom modules of type `command` and type `qml`. | manual/05-the-top-bar.md; docs/omarchy-shell.md |
| OMA-8-046 | The toggle `bar-off` must hide the bar. | bin/omarchy-toggle-bar |

### Third-party plugins

| ID | Requirement | Source |
|---|---|---|
| OMA-8-047 | Third-party plugins must be git repositories in `~/.config/omarchy/plugins/<id>`. | bin/omarchy-plugin-* |
| OMA-8-048 | Third-party plugins must start disabled. | bin/omarchy-plugin-add |
| OMA-8-049 | Third-party plugins run without a sandbox. | manual/32-shell-plugins.md |

### Notifications

| ID | Requirement | Source |
|---|---|---|
| OMA-8-050 | The notification history must keep 10 entries. | shell/plugins/notifications |
| OMA-8-051 | Do-not-disturb must silence notifications. `omarchy-toggle-notification-silencing` must switch it. | bin/omarchy-toggle-notification-silencing |

### Idle and lock

| ID | Requirement | Source |
|---|---|---|
| OMA-8-052 | The idle service must start the screensaver after 150 s. | config/omarchy/shell.json |
| OMA-8-053 | The idle service must lock the session after 300 s. | config/omarchy/shell.json |
| OMA-8-054 | `omarchy-toggle-idle` must switch the idle lock on and off. | bin/omarchy-toggle-idle |
| OMA-8-055 | `omarchy-system-lock` must run `omarchy-shell lock lock`, set the xkb layout to index 0, run `1password --lock` and stop `ttfx` and the screensaver. | bin/omarchy-system-lock |
| OMA-8-056 | The lock PAM stack must use `pam_faillock` (deny 10, unlock 120 s) and `pam_unix`. | bin/omarchy-apply-lock |
| OMA-8-057 | The lock PAM stack must use the fingerprint only when prints are enrolled. | bin/omarchy-apply-lock |
| OMA-8-058 | `omarchy-sleep-lock.service` must lock the session before sleep. | default/systemd/user/omarchy-sleep-lock.service |

### Menu

| ID | Requirement | Source |
|---|---|---|
| OMA-8-059 | `omarchy-menu [toggle] [<id>]` must open the menu at the root or at an entry. | bin/omarchy-menu |
| OMA-8-060 | The menu roots must be apps, learn, trigger, style, setup, install, remove, update, about and system. | default/omarchy/omarchy-menu.jsonc |
| OMA-8-061 | User menu extensions must be in `~/.config/omarchy/extensions/omarchy-menu.jsonc`. | config/omarchy/extensions/omarchy-menu.jsonc |
| OMA-8-062 | The launcher must hide the desktop entries in `default/omarchy/launcher.hides`. | default/omarchy/launcher.hides |

The table lists every menu entry. The column Action has the command, the target menu (`menu:`) or the provider (`provider:`). The column Condition has the `when` expression.

| ID | Entry ID | Label | Action | Condition | Source |
|---|---|---|---|---|---|
| OMA-8-063 | `apps` | Apps | `provider:apps` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-064 | `learn` | Learn | (submenu) |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-065 | `trigger` | Trigger | (submenu) |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-066 | `style` | Style | (submenu) |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-067 | `setup` | Setup | (submenu) |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-068 | `install` | Install | (submenu) |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-069 | `remove` | Remove | (submenu) |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-070 | `update` | Update | (submenu) |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-071 | `about` | About | `omarchy-launch-about` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-072 | `system` | System | (submenu) |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-073 | `system.screensaver` | Screensaver | `omarchy-launch-screensaver force` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-074 | `system.lock` | Lock | `omarchy-system-lock` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-075 | `system.suspend` | Suspend | `systemctl suspend` | `! omarchy-toggle-enabled suspend-off` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-076 | `system.hibernate` | Hibernate | `systemctl hibernate` | `omarchy-hibernation-available` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-077 | `system.logout` | Logout | `omarchy-system-logout` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-078 | `system.reboot` | Reboot | `omarchy-system-reboot` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-079 | `system.shutdown` | Shutdown | `omarchy-system-shutdown` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-080 | `learn.keybindings` | Keybindings | `omarchy-menu-keybindings` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-081 | `learn.omarchy` | Omarchy | `omarchy-launch-webapp 'https://omarchy.org/manual/'` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-082 | `learn.hyprland` | Hyprland | `omarchy-launch-webapp 'https://wiki.hypr.land/'` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-083 | `learn.arch` | Arch | `omarchy-launch-webapp 'https://wiki.archlinux.org/title/Main_page'` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-084 | `learn.neovim` | Neovim | `omarchy-launch-webapp 'https://www.lazyvim.org/keymaps'` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-085 | `learn.bash` | Bash | `omarchy-launch-webapp 'https://devhints.io/bash'` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-086 | `learn.tmux-keybindings` | Tmux | `omarchy-menu-tmux-keybindings` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-087 | `learn.herdr-keybindings` | Herdr | `omarchy-menu-herdr-keybindings` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-088 | `learn.community` | Community | `omarchy-launch-discord-community` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-089 | `trigger.emoji` | Emoji | `omarchy-menu-emoji` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-090 | `trigger.reminder` | Reminder | (submenu) |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-091 | `trigger.capture` | Capture | (submenu) |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-092 | `trigger.capture.screenshot` | Screenshot | `omarchy-capture-screenshot` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-093 | `trigger.capture.screenrecord.stop` | Stop Screenrecording | `omarchy-capture-screenrecording --stop-recording` | `pgrep -f '^gpu-screen-recorder'` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-094 | `trigger.capture.screenrecord` | Screenrecord | (submenu) |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-095 | `trigger.capture.text` | Text | `omarchy-capture-text` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-096 | `trigger.capture.qr` | QR Code | `omarchy-capture-qr` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-097 | `trigger.capture.color` | Color | `pkill hyprpicker \|\| hyprpicker -a` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-098 | `trigger.capture.screenrecord.no-audio` | With no audio | `omarchy-capture-screenrecording` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-099 | `trigger.capture.screenrecord.desktop-audio` | With desktop audio | `omarchy-capture-screenrecording --with-desktop-audio` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-100 | `trigger.capture.screenrecord.microphone` | With desktop + microphone audio | `omarchy-capture-screenrecording --with-desktop-audio --with-microphone-audio` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-101 | `trigger.capture.screenrecord.webcam` | With desktop + microphone audio + webcam | `omarchy-capture-screenrecording-with-webcam` | `omarchy-hw-webcam` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-102 | `trigger.transcode` | Transcode | `omarchy-transcode` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-103 | `trigger.share` | Share | (submenu) |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-104 | `trigger.toggle` | Toggle | (submenu) |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-105 | `trigger.hardware` | Hardware | (submenu) |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-106 | `trigger.tests` | Speed Test | (submenu) |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-107 | `trigger.hardware.laptop-display` | Laptop Display | `omarchy-hyprland-monitor-internal toggle` | `omarchy-hw-laptop` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-108 | `trigger.hardware.mirror-display` | Mirror Display | `omarchy-hyprland-monitor-internal-mirror toggle` | `omarchy-hw-laptop` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-109 | `trigger.hardware.hybrid-gpu` | Hybrid GPU | `omarchy-launch-floating-terminal-with-presentation omarchy-toggle-hybrid-gpu` | `omarchy-hw-hybrid-gpu` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-110 | `trigger.hardware.touchpad` | Touchpad | `omarchy-toggle-touchpad` | `omarchy-hw-touchpad` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-111 | `trigger.hardware.touchpad-haptics` | Touchpad Haptics | (submenu) |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-112 | `trigger.hardware.touchpad-haptics.low` | low | `dell-xps-touchpad-haptics set low` | `omarchy-hw-dell-xps-haptic-touchpad && omarchy-cmd-present d` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-113 | `trigger.hardware.touchpad-haptics.mid` | mid | `dell-xps-touchpad-haptics set mid` | `omarchy-hw-dell-xps-haptic-touchpad && omarchy-cmd-present d` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-114 | `trigger.hardware.touchpad-haptics.high` | high | `dell-xps-touchpad-haptics set high` | `omarchy-hw-dell-xps-haptic-touchpad && omarchy-cmd-present d` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-115 | `trigger.hardware.touchscreen` | Touchscreen | `omarchy-toggle-touchscreen` | `omarchy-hw-touchscreen` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-116 | `trigger.reminder.set` | Set one | `omarchy-reminder -i` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-117 | `trigger.reminder.show` | Show all | `omarchy-reminder show` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-118 | `trigger.reminder.clear` | Clear all | `omarchy-reminder clear` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-119 | `trigger.share.clipboard` | Clipboard | `omarchy-menu-share clipboard` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-120 | `trigger.share.file` | File | `omarchy-menu-share file` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-121 | `trigger.share.folder` | Folder | `omarchy-menu-share folder` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-122 | `trigger.share.receive` | Receive | `uwsm-app -- localsend` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-123 | `trigger.toggle.idle-lock` | Stay Awake | `omarchy-toggle-idle` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-124 | `trigger.toggle.notifications` | Notifications | `omarchy-toggle-notification-silencing` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-125 | `trigger.toggle.crash-capture` | Crash Capture | `omarchy-toggle-crash-capture` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-126 | `trigger.toggle.screensaver` | Screensaver | `omarchy-toggle-screensaver` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-127 | `trigger.toggle.nightlight` | Nightlight | `omarchy-toggle-nightlight` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-128 | `trigger.toggle.top-bar` | Menu Bar | `omarchy-toggle-bar` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-129 | `trigger.toggle.battery-percentage` | Battery Percentage | `omarchy-shell omarchy.power togglePercentage` | `omarchy-hw-laptop` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-130 | `trigger.toggle.workspace-layout` | Workspace Layout | `omarchy-hyprland-workspace-layout-toggle` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-131 | `trigger.toggle.window-gaps` | Window Gaps | `omarchy-hyprland-window-gaps-toggle` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-132 | `trigger.toggle.one-window-ratio` | 1-Window Ratio | `omarchy-hyprland-window-single-square-aspect-toggle` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-133 | `trigger.tests.network-speedtest` | Network Speed Test | `omarchy-shell shell summon omarchy.speedtest` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-134 | `trigger.tests.disk-speedtest` | Disk Speed Test | `omarchy-shell shell summon omarchy.disk-speedtest` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-135 | `style.theme` | Theme | `theme=$(omarchy-theme-switcher); [[ -n $theme ]] && omarchy-theme-set "$theme"` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-136 | `style.background` | Background | `background=$(omarchy-theme-bg-switcher); [[ -n $background ]] && omarchy-theme-bg-set "$background"` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-137 | `style.unlock` | Unlock | `unlock=$(omarchy-plymouth-switcher); if [[ $unlock == default ]]; then omarchy-launch-floating-terminal-with-p` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-138 | `style.font` | Font | `provider:fonts` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-139 | `style.bar` | Menu Bar | (submenu) |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-140 | `style.bar.position` | Position | (submenu) |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-141 | `style.bar.transparency` | Transparency | `omarchy-bar transparent toggle` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-142 | `style.hyprland` | Hyprland | `omarchy-launch-config-editor "$HOME/.config/hypr/looknfeel.lua"` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-143 | `style.screensaver` | Screensaver | (submenu) |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-144 | `style.about` | About | (submenu) |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-145 | `style.bar.position.top` | Top | `omarchy-bar position top` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-146 | `style.bar.position.bottom` | Bottom | `omarchy-bar position bottom` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-147 | `style.bar.position.left` | Left | `omarchy-bar position left` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-148 | `style.bar.position.right` | Right | `omarchy-bar position right` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-149 | `style.about.text` | Edit Text | `omarchy-branding-about text` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-150 | `style.about.image` | Set From Image | `omarchy-branding-about image` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-151 | `style.about.default` | Restore Default | `omarchy-branding-about reset` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-152 | `style.screensaver.text` | Edit Text | `omarchy-branding-screensaver text` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-153 | `style.screensaver.image` | Set From Image | `omarchy-branding-screensaver image` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-154 | `style.screensaver.default` | Restore Default | `omarchy-branding-screensaver reset` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-155 | `setup.monitors` | Monitors | `omarchy-launch-config-editor "$HOME/.config/hypr/monitors.lua"` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-156 | `setup.keybindings` | Keybindings | `omarchy-launch-config-editor "$HOME/.config/hypr/bindings.lua"` | `[[ -f ~/.config/hypr/bindings.lua ]]` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-157 | `setup.input` | Input | `omarchy-launch-config-editor "$HOME/.config/hypr/input.lua"` | `[[ -f ~/.config/hypr/input.lua ]]` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-158 | `setup.network` | Network | (submenu) |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-159 | `setup.network.dns` | DNS | (submenu) |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-160 | `setup.network.dns.dhcp` | DHCP | `omarchy-dns DHCP` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-161 | `setup.network.dns.cloudflare` | Cloudflare | `omarchy-dns Cloudflare` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-162 | `setup.network.dns.google` | Google | `omarchy-dns Google` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-163 | `setup.network.dns.custom` | Custom | `omarchy-launch-floating-terminal-with-presentation 'omarchy-dns Custom'` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-164 | `setup.network.qr` | QR Code | `omarchy-shell shell summon omarchy.wifiqr` | `[[ $(omarchy-network-status) == wifi* ]]` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-165 | `setup.default` | Defaults | (submenu) |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-166 | `setup.default.agent` | Agent | (submenu) |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-167 | `setup.default.agent.claude` | Claude | `omarchy-default-agent claude` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-168 | `setup.default.agent.codex` | Codex | `omarchy-default-agent codex` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-169 | `setup.default.agent.copilot` | Copilot | `omarchy-default-agent copilot` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-170 | `setup.default.agent.crush` | Crush | `omarchy-default-agent crush` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-171 | `setup.default.agent.cursor-agent` | Cursor CLI | `omarchy-default-agent cursor-agent` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-172 | `setup.default.agent.gemini` | Gemini | `omarchy-default-agent gemini` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-173 | `setup.default.agent.grok` | Grok | `omarchy-default-agent grok` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-174 | `setup.default.agent.hermes` | Hermes | `omarchy-default-agent hermes` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-175 | `setup.default.agent.muse` | Muse Code | `omarchy-default-agent muse` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-176 | `setup.default.agent.omp` | omp | `omarchy-default-agent omp` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-177 | `setup.default.agent.openclaw` | OpenClaw | `omarchy-default-agent openclaw` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-178 | `setup.default.agent.opencode` | OpenCode | `omarchy-default-agent opencode` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-179 | `setup.default.agent.pi` | Pi | `omarchy-default-agent pi` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-180 | `setup.default.browser` | Browser | (submenu) |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-181 | `setup.default.browser.chromium` | Chromium | `omarchy-default-browser chromium` | `omarchy-cmd-present chromium` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-182 | `setup.default.browser.chrome` | Chrome | `omarchy-default-browser chrome` | `omarchy-cmd-present google-chrome-stable` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-183 | `setup.default.browser.brave` | Brave | `omarchy-default-browser brave` | `omarchy-cmd-present brave` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-184 | `setup.default.browser.brave-origin` | Brave Origin | `omarchy-default-browser brave-origin` | `omarchy-cmd-present brave-origin` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-185 | `setup.default.browser.edge` | Edge | `omarchy-default-browser edge` | `omarchy-cmd-present microsoft-edge-stable` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-186 | `setup.default.browser.firefox` | Firefox | `omarchy-default-browser firefox` | `omarchy-cmd-present firefox` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-187 | `setup.default.browser.zen` | Zen | `omarchy-default-browser zen` | `omarchy-cmd-present zen-browser` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-188 | `setup.default.terminal` | Terminal | (submenu) |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-189 | `setup.default.terminal.alacritty` | Alacritty | `omarchy-default-terminal alacritty` | `omarchy-cmd-present alacritty` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-190 | `setup.default.terminal.foot` | Foot | `omarchy-default-terminal foot` | `omarchy-cmd-present foot` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-191 | `setup.default.terminal.ghostty` | Ghostty | `omarchy-default-terminal ghostty` | `omarchy-cmd-present ghostty` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-192 | `setup.default.terminal.kitty` | Kitty | `omarchy-default-terminal kitty` | `omarchy-cmd-present kitty` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-193 | `setup.default.editor` | Editor | (submenu) |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-194 | `setup.default.editor.neovim` | Neovim | `omarchy-default-editor nvim` | `omarchy-cmd-present nvim` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-195 | `setup.default.editor.vscode` | VSCode | `omarchy-default-editor code` | `omarchy-cmd-present code` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-196 | `setup.default.editor.cursor` | Cursor | `omarchy-default-editor cursor` | `omarchy-cmd-present cursor` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-197 | `setup.default.editor.zed` | Zed | `omarchy-default-editor zed` | `omarchy-cmd-present zeditor` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-198 | `setup.default.editor.sublime` | Sublime Text | `omarchy-default-editor sublime_text` | `omarchy-cmd-present sublime_text` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-199 | `setup.default.editor.helix` | Helix | `omarchy-default-editor helix` | `omarchy-cmd-present helix` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-200 | `setup.default.editor.vim` | Vim | `omarchy-default-editor vim` | `omarchy-cmd-present vim` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-201 | `setup.default.editor.emacs` | Emacs | `omarchy-default-editor emacs` | `omarchy-cmd-present emacs` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-202 | `setup.plugin` | Plugins | (submenu) |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-203 | `setup.plugin.enable` | Enable Plugin | `omarchy-menu-plugin enable` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-204 | `setup.plugin.disable` | Disable Plugin | `omarchy-menu-plugin disable` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-205 | `setup.plugin.add` | Add Plugin | `omarchy-launch-floating-terminal-with-presentation 'omarchy-plugin-add'` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-206 | `setup.plugin.clone` | Clone Plugin | `omarchy-menu-plugin clone` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-207 | `setup.plugin.remove` | Remove Plugin | `omarchy-menu-plugin remove` | `compgen -G "$HOME/.config/omarchy/plugins/*/manifest.json"` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-208 | `setup.security` | Security | (submenu) |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-209 | `setup.config` | Config | (submenu) |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-210 | `setup.security.fingerprint` | Fingerprint | `omarchy-launch-floating-terminal-with-presentation omarchy-setup-security-fingerprint` | `omarchy-hw-fingerprint` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-211 | `setup.security.fido2` | Fido2 | `omarchy-launch-floating-terminal-with-presentation omarchy-setup-security-fido2` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-212 | `setup.security.sshd` | SSHD | `omarchy-launch-floating-terminal-with-presentation omarchy-setup-security-sshd` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-213 | `setup.security.passwordless-sudo` | Passwordless Sudo | `omarchy-launch-floating-terminal-with-presentation omarchy-sudo-passwordless` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-214 | `setup.security.sudoless-docker` | Sudoless Docker | `omarchy-launch-floating-terminal-with-presentation omarchy-setup-security-sudoless-docker` | `omarchy-sudo-docker --configured` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-215 | `setup.config.hyprland` | Hyprland | `omarchy-launch-config-editor "$HOME/.config/hypr/hyprland.lua"` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-216 | `setup.config.hyprsunset` | Hyprsunset | `omarchy-launch-config-editor ~/.config/hypr/hyprsunset.conf && omarchy-restart-hyprsunset` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-217 | `setup.config.xcompose` | XCompose | `omarchy-launch-config-editor ~/.XCompose && omarchy-restart-xcompose` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-218 | `setup.direct-boot` | Direct Boot | `omarchy-launch-floating-terminal-with-presentation omarchy-setup-direct-boot` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-219 | `setup.reset` | Reset Computer | `omarchy-launch-floating-terminal-with-presentation omarchy-system-factory-reset` | `[[ $(findmnt -no FSTYPE /) == btrfs ]]` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-220 | `install.package` | Package | `xdg-terminal-exec --app-id=org.omarchy.terminal omarchy-pkg-install` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-221 | `install.aur` | AUR | `xdg-terminal-exec --app-id=org.omarchy.terminal omarchy-pkg-aur-install` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-222 | `install.webapp` | Web App | `omarchy-launch-floating-terminal-with-presentation omarchy-webapp-install` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-223 | `install.tui` | TUI | `omarchy-launch-floating-terminal-with-presentation omarchy-tui-install` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-224 | `install.style` | Style | (submenu) |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-225 | `install.style.theme` | Theme | `omarchy-launch-floating-terminal-with-presentation omarchy-theme-install` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-226 | `install.style.background` | Background | `omarchy-theme-bg-install` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-227 | `install.style.font` | Font | (submenu) |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-228 | `install.style.font.cascadia` | Cascadia Mono | `omarchy-install-font 'Cascadia Mono' ttf-cascadia-mono-nerd 'CaskaydiaMono Nerd Font'` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-229 | `install.style.font.meslo` | Meslo LG Mono | `omarchy-install-font 'Meslo LG Mono' ttf-meslo-nerd 'MesloLGL Nerd Font'` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-230 | `install.style.font.fira` | Fira Code | `omarchy-install-font 'Fira Code' ttf-firacode-nerd 'FiraCode Nerd Font'` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-231 | `install.style.font.victor` | Victor Code | `omarchy-install-font 'Victor Code' ttf-victor-mono-nerd 'VictorMono Nerd Font'` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-232 | `install.style.font.bitstream` | Bitstream Vera Mono | `omarchy-install-font 'Bitstream Vera Code' ttf-bitstream-vera-mono-nerd 'BitstromWera Nerd Font'` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-233 | `install.style.font.iosevka` | Iosevka | `omarchy-install-font Iosevka ttf-iosevka-nerd 'Iosevka Nerd Font Mono'` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-234 | `install.service` | Service | (submenu) |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-235 | `install.development` | Development | (submenu) |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-236 | `install.editor` | Editor | (submenu) |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-237 | `install.terminal` | Terminal | (submenu) |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-238 | `install.browser` | Browser | (submenu) |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-239 | `install.ai` | AI | (submenu) |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-240 | `install.gaming` | Gaming | (submenu) |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-241 | `install.windows` | Windows | `omarchy-launch-floating-terminal-with-presentation 'omarchy-windows-vm install'` | `[[ ! -f $HOME/.local/share/applications/windows-vm.desktop ]` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-242 | `install.preinstalls` | Preinstalls | `omarchy-launch-floating-terminal-with-presentation omarchy-install-preinstalls` | `[[ -f $HOME/.local/state/omarchy/preinstalls-removed ]]` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-243 | `install.browser.chrome` | Chrome | `omarchy-launch-floating-terminal-with-presentation 'omarchy-install-browser chrome'` | `! omarchy-pkg-present google-chrome` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-244 | `install.browser.edge` | Edge | `omarchy-launch-floating-terminal-with-presentation 'omarchy-install-browser edge'` | `! omarchy-pkg-present microsoft-edge-stable-bin` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-245 | `install.browser.brave` | Brave | `omarchy-launch-floating-terminal-with-presentation 'omarchy-install-browser brave'` | `! omarchy-pkg-present brave-bin` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-246 | `install.browser.brave-origin` | Brave Origin | `omarchy-launch-floating-terminal-with-presentation 'omarchy-install-browser brave-origin'` | `! omarchy-pkg-present brave-origin-bin` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-247 | `install.browser.firefox` | Firefox | `omarchy-launch-floating-terminal-with-presentation 'omarchy-install-browser firefox'` | `! omarchy-pkg-present firefox` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-248 | `install.browser.zen` | Zen | `omarchy-launch-floating-terminal-with-presentation 'omarchy-install-browser zen'` | `! omarchy-pkg-present zen-browser-bin` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-249 | `install.service.1password` | 1Password | `omarchy-launch-floating-terminal-with-presentation omarchy-install-service-1password` | `! omarchy-pkg-present 1password` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-250 | `install.service.dropbox` | Dropbox | `omarchy-launch-floating-terminal-with-presentation omarchy-install-service-dropbox` | `! omarchy-pkg-present dropbox` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-251 | `install.service.spotify` | Spotify | `omarchy-launch-floating-terminal-with-presentation omarchy-install-service-spotify` | `! omarchy-pkg-present spotify` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-252 | `install.service.signal` | Signal | `omarchy-launch-floating-terminal-with-presentation omarchy-install-service-signal` | `! omarchy-pkg-present signal-desktop` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-253 | `install.service.tailscale` | Tailscale | `omarchy-launch-floating-terminal-with-presentation omarchy-install-service-tailscale` | `! omarchy-pkg-present tailscale` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-254 | `install.service.nordvpn` | NordVPN | `omarchy-launch-floating-terminal-with-presentation omarchy-install-service-nordvpn` | `! omarchy-pkg-present nordvpn-bin` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-255 | `install.service.once` | ONCE | `omarchy-launch-floating-terminal-with-presentation omarchy-install-service-once` | `! omarchy-pkg-present once-bin` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-256 | `install.service.bitwarden` | Bitwarden | `omarchy-install-and-launch Bitwarden 'bitwarden bitwarden-cli' bitwarden` | `! omarchy-pkg-present bitwarden` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-257 | `install.service.chromium-account` | Chromium Account | `omarchy-launch-floating-terminal-with-presentation omarchy-install-chromium-google-account` | `[[ -f ~/.config/chromium-flags.conf ]] && ! grep -q oauth2-c` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-258 | `install.editor.vscode` | VSCode | `omarchy-launch-floating-terminal-with-presentation omarchy-install-editor-vscode` | `! omarchy-pkg-present visual-studio-code-bin` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-259 | `install.editor.cursor` | Cursor | `omarchy-install-and-launch Cursor cursor-bin cursor` | `! omarchy-pkg-present cursor-bin` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-260 | `install.editor.zed` | Zed | `omarchy-launch-floating-terminal-with-presentation omarchy-install-editor-zed` | `! omarchy-pkg-present zed` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-261 | `install.editor.sublime` | Sublime Text | `omarchy-install-and-launch 'Sublime Text' sublime-text-4 sublime_text` | `! omarchy-pkg-present sublime-text-4` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-262 | `install.editor.helix` | Helix | `omarchy-launch-floating-terminal-with-presentation omarchy-install-editor-helix` | `! omarchy-pkg-present helix` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-263 | `install.editor.vim` | Vim | `omarchy-install-app Vim vim` | `! omarchy-pkg-present vim` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-264 | `install.editor.emacs` | Emacs | `omarchy-launch-floating-terminal-with-presentation omarchy-install-editor-emacs` | `! omarchy-pkg-present omarchy-emacs` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-265 | `install.terminal.alacritty` | Alacritty | `omarchy-launch-floating-terminal-with-presentation 'omarchy-install-terminal alacritty'` | `! omarchy-pkg-present alacritty` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-266 | `install.terminal.foot` | Foot | `omarchy-launch-floating-terminal-with-presentation 'omarchy-install-terminal foot'` | `! omarchy-pkg-present foot` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-267 | `install.terminal.ghostty` | Ghostty | `omarchy-launch-floating-terminal-with-presentation 'omarchy-install-terminal ghostty'` | `! omarchy-pkg-present ghostty` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-268 | `install.terminal.kitty` | Kitty | `omarchy-launch-floating-terminal-with-presentation 'omarchy-install-terminal kitty'` | `! omarchy-pkg-present kitty` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-269 | `install.ai.chatgpt` | ChatGPT Desktop | `omarchy-launch-floating-terminal-with-presentation omarchy-install-ai-chatgpt` | `! omarchy-pkg-present openai-codex-desktop` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-270 | `install.ai.dictation` | Dictation | `omarchy-launch-floating-terminal-with-presentation omarchy-voxtype-install` | `! omarchy-pkg-present voxtype-bin` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-271 | `install.ai.grok-bot` | Grok Bot | `omarchy-install-and-launch 'Grok Bot' grok-bot grok-bot` | `! omarchy-pkg-present grok-bot` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-272 | `install.ai.lm-studio` | LM Studio | `omarchy-install-app 'LM Studio' lmstudio-bin` | `! omarchy-pkg-present lmstudio-bin` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-273 | `install.ai.ollama` | Ollama | `if omarchy-cmd-present nvidia-smi; then ollama_pkg=ollama-cuda; elif omarchy-cmd-present rocminfo; then ollama` | `! omarchy-cmd-present ollama` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-274 | `install.ai.t3-code` | T3 Code | `omarchy-launch-floating-terminal-with-presentation omarchy-install-ai-t3-code` | `! omarchy-pkg-present t3code-bin` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-275 | `install.ai.hermes` | Hermes Desktop | `omarchy-launch-floating-terminal-with-presentation omarchy-install-ai-hermes` | `! omarchy-pkg-present hermes-desktop` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-276 | `install.ai.openclaw` | OpenClaw | `omarchy-launch-floating-terminal-with-presentation omarchy-install-ai-openclaw` | `! omarchy-pkg-present openclaw` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-277 | `install.ai.perplexity` | Perplexity | `omarchy-install-and-launch Perplexity perplexity perplexity` | `! omarchy-pkg-present perplexity` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-278 | `install.gaming.steam` | Steam | `omarchy-launch-floating-terminal-with-presentation omarchy-install-gaming-steam` | `! omarchy-pkg-present steam` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-279 | `install.gaming.retroarch` | RetroArch | `omarchy-launch-floating-terminal-with-presentation omarchy-install-gaming-retroarch` | `! omarchy-pkg-present retroarch` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-280 | `install.gaming.minecraft` | Minecraft | `omarchy-install-and-launch Minecraft minecraft-launcher minecraft-launcher` | `! omarchy-pkg-present minecraft-launcher` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-281 | `install.gaming.geforce-now` | NVIDIA GeForce NOW | `omarchy-launch-floating-terminal-with-presentation omarchy-install-gaming-geforce-now` | `! flatpak info com.nvidia.geforcenow` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-282 | `install.gaming.xbox-cloud` | Xbox Cloud Gaming | `omarchy-launch-floating-terminal-with-presentation omarchy-install-gaming-xbox-cloud` | `[[ ! -f "$HOME/.local/share/applications/Xbox Cloud Gaming.d` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-283 | `install.gaming.xbox-controllers` | Xbox Controllers | `omarchy-launch-floating-terminal-with-presentation omarchy-install-gaming-xbox-controllers` | `! omarchy-pkg-present xpadneo-dkms` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-284 | `install.gaming.battlenet` | Battle.net | `omarchy-launch-floating-terminal-with-presentation omarchy-install-gaming-battlenet` | `[[ ! -d $HOME/Games/battlenet ]]` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-285 | `install.gaming.lutris` | Lutris | `omarchy-launch-floating-terminal-with-presentation omarchy-install-gaming-lutris` | `! omarchy-pkg-present lutris` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-286 | `install.gaming.heroic` | Heroic (Epic Games) | `omarchy-launch-floating-terminal-with-presentation omarchy-install-gaming-heroic` | `! omarchy-pkg-present heroic-games-launcher-bin` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-287 | `install.gaming.retro-launcher` | RetroArch Game Launcher | `omarchy-games-retro-install` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-288 | `install.development.rails` | Ruby on Rails | `omarchy-launch-floating-terminal-with-presentation 'omarchy-install-dev-env ruby'` | `[[ ! -d $HOME/.local/share/mise/installs/ruby ]]` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-289 | `install.development.docker-dbs` | Docker DB | `omarchy-launch-floating-terminal-with-presentation omarchy-install-docker-dbs` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-290 | `install.development.javascript` | JavaScript | (submenu) |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-291 | `install.development.go` | Go | `omarchy-launch-floating-terminal-with-presentation 'omarchy-install-dev-env go'` | `[[ ! -d $HOME/.local/share/mise/installs/go ]]` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-292 | `install.development.php` | PHP | (submenu) |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-293 | `install.development.python` | Python | `omarchy-launch-floating-terminal-with-presentation 'omarchy-install-dev-env python'` | `[[ ! -d $HOME/.local/share/mise/installs/python ]]` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-294 | `install.development.elixir` | Elixir | (submenu) |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-295 | `install.development.zig` | Zig | `omarchy-launch-floating-terminal-with-presentation 'omarchy-install-dev-env zig'` | `[[ ! -d $HOME/.local/share/mise/installs/zig ]]` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-296 | `install.development.rust` | Rust | `omarchy-launch-floating-terminal-with-presentation 'omarchy-install-dev-env rust'` | `[[ ! -d $HOME/.rustup ]]` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-297 | `install.development.java` | Java | `omarchy-launch-floating-terminal-with-presentation 'omarchy-install-dev-env java'` | `[[ ! -d $HOME/.local/share/mise/installs/java ]]` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-298 | `install.development.dotnet` | .NET | `omarchy-launch-floating-terminal-with-presentation 'omarchy-install-dev-env dotnet'` | `[[ ! -d $HOME/.local/share/mise/installs/dotnet ]]` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-299 | `install.development.ocaml` | OCaml | `omarchy-launch-floating-terminal-with-presentation 'omarchy-install-dev-env ocaml'` | `[[ ! -d $HOME/.opam ]]` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-300 | `install.development.clojure` | Clojure | `omarchy-launch-floating-terminal-with-presentation 'omarchy-install-dev-env clojure'` | `[[ ! -d $HOME/.local/share/mise/installs/clojure ]]` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-301 | `install.development.scala` | Scala | `omarchy-launch-floating-terminal-with-presentation 'omarchy-install-dev-env scala'` | `[[ ! -d $HOME/.local/share/mise/installs/scala ]]` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-302 | `install.development.javascript.node` | Node.js | `omarchy-launch-floating-terminal-with-presentation 'omarchy-install-dev-env node'` | `[[ ! -d $HOME/.local/share/mise/installs/node ]]` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-303 | `install.development.javascript.bun` | Bun | `omarchy-launch-floating-terminal-with-presentation 'omarchy-install-dev-env bun'` | `[[ ! -d $HOME/.local/share/mise/installs/bun ]]` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-304 | `install.development.javascript.deno` | Deno | `omarchy-launch-floating-terminal-with-presentation 'omarchy-install-dev-env deno'` | `[[ ! -d $HOME/.local/share/mise/installs/deno ]]` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-305 | `install.development.php.php` | PHP | `omarchy-launch-floating-terminal-with-presentation 'omarchy-install-dev-env php'` | `! omarchy-pkg-present php` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-306 | `install.development.php.laravel` | Laravel | `omarchy-launch-floating-terminal-with-presentation 'omarchy-install-dev-env laravel'` | `[[ ! -x $HOME/.config/composer/vendor/bin/laravel ]]` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-307 | `install.development.php.symfony` | Symfony | `omarchy-launch-floating-terminal-with-presentation 'omarchy-install-dev-env symfony'` | `! omarchy-pkg-present symfony-cli` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-308 | `install.development.elixir.elixir` | Elixir | `omarchy-launch-floating-terminal-with-presentation 'omarchy-install-dev-env elixir'` | `[[ ! -d $HOME/.local/share/mise/installs/elixir ]]` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-309 | `install.development.elixir.phoenix` | Phoenix | `omarchy-launch-floating-terminal-with-presentation 'omarchy-install-dev-env phoenix'` | `! compgen -G "$HOME/.mix/archives/phx_new*"` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-310 | `remove.package` | Package | `xdg-terminal-exec --app-id=org.omarchy.terminal omarchy-pkg-remove` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-311 | `remove.webapp` | Web App | `omarchy-webapp-remove` | `grep -qE '^Exec=.*(omarchy-launch-webapp\|omarchy-webapp-hand` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-312 | `remove.tui` | TUI | `omarchy-tui-remove` | `grep -qE '^Exec=.*(\$TERMINAL\|xdg-terminal-exec).*-e' $HOME/` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-313 | `remove.development` | Development | (submenu) |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-314 | `remove.theme` | Theme | `omarchy-theme-remove` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-315 | `remove.browser` | Browser | (submenu) |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-316 | `remove.dictation` | Dictation | `omarchy-launch-floating-terminal-with-presentation omarchy-voxtype-remove` | `omarchy-pkg-present voxtype-bin` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-317 | `remove.gaming` | Gaming | (submenu) |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-318 | `remove.service` | Services | (submenu) |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-319 | `remove.windows` | Windows | `omarchy-launch-floating-terminal-with-presentation 'omarchy-windows-vm remove'` | `[[ -f $HOME/.local/share/applications/windows-vm.desktop ]]` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-320 | `remove.preinstalls` | Preinstalls | `omarchy-launch-floating-terminal-with-presentation omarchy-remove-preinstalls` | `[[ ! -f $HOME/.local/state/omarchy/preinstalls-removed ]]` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-321 | `remove.security` | Security | (submenu) |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-322 | `remove.security.fingerprint` | Fingerprint | `omarchy-launch-floating-terminal-with-presentation omarchy-remove-security-fingerprint` | `omarchy-pkg-present fprintd` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-323 | `remove.security.fido2` | Fido2 | `omarchy-launch-floating-terminal-with-presentation omarchy-remove-security-fido2` | `omarchy-pkg-present pam-u2f` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-324 | `remove.security.sshd` | SSHD | `omarchy-launch-floating-terminal-with-presentation omarchy-remove-security-sshd` | `systemctl is-enabled --quiet sshd` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-325 | `remove.security.sudoless-docker` | Sudoless Docker | `omarchy-launch-floating-terminal-with-presentation omarchy-remove-security-sudoless-docker` | `! omarchy-sudo-docker --configured` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-326 | `remove.ai.hermes` | Hermes Desktop | `omarchy-launch-floating-terminal-with-presentation omarchy-remove-ai-hermes` | `omarchy-pkg-present hermes-desktop` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-327 | `remove.browser.chrome` | Chrome | `omarchy-launch-floating-terminal-with-presentation 'omarchy-remove-browser chrome'` | `omarchy-pkg-present google-chrome` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-328 | `remove.browser.edge` | Edge | `omarchy-launch-floating-terminal-with-presentation 'omarchy-remove-browser edge'` | `omarchy-pkg-present microsoft-edge-stable-bin` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-329 | `remove.browser.brave` | Brave | `omarchy-launch-floating-terminal-with-presentation 'omarchy-remove-browser brave'` | `omarchy-pkg-present brave-bin` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-330 | `remove.browser.brave-origin` | Brave Origin | `omarchy-launch-floating-terminal-with-presentation 'omarchy-remove-browser brave-origin'` | `omarchy-pkg-present brave-origin-bin` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-331 | `remove.browser.firefox` | Firefox | `omarchy-launch-floating-terminal-with-presentation 'omarchy-remove-browser firefox'` | `omarchy-pkg-present firefox` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-332 | `remove.browser.zen` | Zen | `omarchy-launch-floating-terminal-with-presentation 'omarchy-remove-browser zen'` | `omarchy-pkg-present zen-browser-bin` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-333 | `remove.service.dropbox` | Dropbox | `omarchy-launch-floating-terminal-with-presentation omarchy-remove-service-dropbox` | `omarchy-pkg-present dropbox` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-334 | `remove.service.tailscale` | Tailscale | `omarchy-launch-floating-terminal-with-presentation omarchy-remove-service-tailscale` | `omarchy-pkg-present tailscale` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-335 | `remove.gaming.steam` | Steam | `omarchy-launch-floating-terminal-with-presentation omarchy-remove-gaming-steam` | `omarchy-pkg-present steam` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-336 | `remove.gaming.retroarch` | RetroArch | `omarchy-launch-floating-terminal-with-presentation omarchy-remove-gaming-retroarch` | `omarchy-pkg-present retroarch` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-337 | `remove.gaming.minecraft` | Minecraft | `omarchy-launch-floating-terminal-with-presentation omarchy-remove-gaming-minecraft` | `omarchy-pkg-present minecraft-launcher` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-338 | `remove.gaming.geforce-now` | NVIDIA GeForce NOW | `omarchy-launch-floating-terminal-with-presentation omarchy-remove-gaming-geforce-now` | `flatpak info com.nvidia.geforcenow` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-339 | `remove.gaming.xbox-cloud` | Xbox Cloud Gaming | `omarchy-launch-floating-terminal-with-presentation omarchy-remove-gaming-xbox-cloud` | `[[ -f "$HOME/.local/share/applications/Xbox Cloud Gaming.des` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-340 | `remove.gaming.xbox-controllers` | Xbox Controllers (󰂯) | `omarchy-launch-floating-terminal-with-presentation omarchy-remove-gaming-xbox-controllers` | `omarchy-pkg-present xpadneo-dkms` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-341 | `remove.gaming.battlenet` | Battle.net | `omarchy-launch-floating-terminal-with-presentation omarchy-remove-gaming-battlenet` | `[[ -d $HOME/Games/battlenet ]]` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-342 | `remove.gaming.lutris` | Lutris | `omarchy-launch-floating-terminal-with-presentation omarchy-remove-gaming-lutris` | `omarchy-pkg-present lutris` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-343 | `remove.gaming.heroic` | Heroic (Epic Games) | `omarchy-launch-floating-terminal-with-presentation omarchy-remove-gaming-heroic` | `omarchy-pkg-present heroic-games-launcher-bin` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-344 | `remove.development.rails` | Ruby on Rails | `omarchy-launch-floating-terminal-with-presentation 'omarchy-remove-dev-env ruby'` | `[[ -d $HOME/.local/share/mise/installs/ruby ]]` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-345 | `remove.development.javascript` | JavaScript | (submenu) |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-346 | `remove.development.go` | Go | `omarchy-launch-floating-terminal-with-presentation 'omarchy-remove-dev-env go'` | `[[ -d $HOME/.local/share/mise/installs/go ]]` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-347 | `remove.development.php` | PHP | (submenu) |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-348 | `remove.development.python` | Python | `omarchy-launch-floating-terminal-with-presentation 'omarchy-remove-dev-env python'` | `[[ -d $HOME/.local/share/mise/installs/python ]]` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-349 | `remove.development.elixir` | Elixir | (submenu) |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-350 | `remove.development.zig` | Zig | `omarchy-launch-floating-terminal-with-presentation 'omarchy-remove-dev-env zig'` | `[[ -d $HOME/.local/share/mise/installs/zig ]]` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-351 | `remove.development.rust` | Rust | `omarchy-launch-floating-terminal-with-presentation 'omarchy-remove-dev-env rust'` | `[[ -d $HOME/.rustup ]]` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-352 | `remove.development.java` | Java | `omarchy-launch-floating-terminal-with-presentation 'omarchy-remove-dev-env java'` | `[[ -d $HOME/.local/share/mise/installs/java ]]` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-353 | `remove.development.dotnet` | .NET | `omarchy-launch-floating-terminal-with-presentation 'omarchy-remove-dev-env dotnet'` | `[[ -d $HOME/.local/share/mise/installs/dotnet ]]` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-354 | `remove.development.ocaml` | OCaml | `omarchy-launch-floating-terminal-with-presentation 'omarchy-remove-dev-env ocaml'` | `[[ -d $HOME/.opam ]]` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-355 | `remove.development.clojure` | Clojure | `omarchy-launch-floating-terminal-with-presentation 'omarchy-remove-dev-env clojure'` | `[[ -d $HOME/.local/share/mise/installs/clojure ]]` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-356 | `remove.development.scala` | Scala | `omarchy-launch-floating-terminal-with-presentation 'omarchy-remove-dev-env scala'` | `[[ -d $HOME/.local/share/mise/installs/scala ]]` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-357 | `remove.development.javascript.node` | Node.js | `omarchy-launch-floating-terminal-with-presentation 'omarchy-remove-dev-env node'` | `[[ -d $HOME/.local/share/mise/installs/node ]]` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-358 | `remove.development.javascript.bun` | Bun | `omarchy-launch-floating-terminal-with-presentation 'omarchy-remove-dev-env bun'` | `[[ -d $HOME/.local/share/mise/installs/bun ]]` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-359 | `remove.development.javascript.deno` | Deno | `omarchy-launch-floating-terminal-with-presentation 'omarchy-remove-dev-env deno'` | `[[ -d $HOME/.local/share/mise/installs/deno ]]` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-360 | `remove.development.php.php` | PHP | `omarchy-launch-floating-terminal-with-presentation 'omarchy-remove-dev-env php'` | `omarchy-pkg-present php` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-361 | `remove.development.php.laravel` | Laravel | `omarchy-launch-floating-terminal-with-presentation 'omarchy-remove-dev-env laravel'` | `[[ -x $HOME/.config/composer/vendor/bin/laravel ]]` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-362 | `remove.development.php.symfony` | Symfony | `omarchy-launch-floating-terminal-with-presentation 'omarchy-remove-dev-env symfony'` | `omarchy-pkg-present symfony-cli` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-363 | `remove.development.elixir.elixir` | Elixir | `omarchy-launch-floating-terminal-with-presentation 'omarchy-remove-dev-env elixir'` | `[[ -d $HOME/.local/share/mise/installs/elixir ]]` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-364 | `remove.development.elixir.phoenix` | Phoenix | `omarchy-launch-floating-terminal-with-presentation 'omarchy-remove-dev-env phoenix'` | `[[ -d $HOME/.local/share/mise/installs/elixir ]]` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-365 | `remove.ai` | AI | (submenu) |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-366 | `remove.ai.t3-code` | T3 Code | `omarchy-launch-floating-terminal-with-presentation omarchy-remove-ai-t3-code` | `omarchy-pkg-present t3code-bin` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-367 | `remove.ai.openclaw` | OpenClaw | `omarchy-launch-floating-terminal-with-presentation omarchy-remove-ai-openclaw` | `omarchy-pkg-present openclaw` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-368 | `remove.ai.perplexity` | Perplexity | `omarchy-launch-floating-terminal-with-presentation omarchy-remove-ai-perplexity` | `omarchy-pkg-present perplexity` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-369 | `update.omarchy` | Omarchy | `omarchy-launch-floating-terminal-with-presentation omarchy-update` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-370 | `update.channel` | Channel | (submenu) |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-371 | `update.config` | Config | (submenu) |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-372 | `update.themes` | Extra Themes | `omarchy-launch-floating-terminal-with-presentation omarchy-theme-update` | `omarchy-theme-extras` | default/omarchy/omarchy-menu.jsonc |
| OMA-8-373 | `update.process` | Process | (submenu) |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-374 | `update.hardware` | Hardware | (submenu) |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-375 | `update.firmware` | Firmware | `omarchy-launch-floating-terminal-with-presentation omarchy-update-firmware` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-376 | `update.password` | Password | (submenu) |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-377 | `update.timezone` | Timezone | `omarchy-menu-timezone` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-378 | `update.time` | Time | `omarchy-launch-floating-terminal-with-presentation omarchy-update-time` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-379 | `update.channel.stable` | Stable | `omarchy-launch-floating-terminal-with-presentation 'omarchy-channel-set stable'` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-380 | `update.channel.rc` | RC | `omarchy-launch-floating-terminal-with-presentation 'omarchy-channel-set rc'` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-381 | `update.channel.edge` | Edge | `omarchy-launch-floating-terminal-with-presentation 'omarchy-channel-set edge'` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-382 | `update.channel.dev` | Dev | `omarchy-launch-floating-terminal-with-presentation 'omarchy-channel-set dev'` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-383 | `update.process.hyprsunset` | Hyprsunset | `omarchy-restart-hyprsunset` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-384 | `update.process.shell` | Shell | `omarchy-restart-shell` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-385 | `update.config.hyprland` | Hyprland | `omarchy-launch-floating-terminal-with-presentation omarchy-refresh-hyprland` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-386 | `update.config.hyprsunset` | Hyprsunset | `omarchy-launch-floating-terminal-with-presentation omarchy-refresh-hyprsunset` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-387 | `update.config.plymouth` | Plymouth | `omarchy-launch-floating-terminal-with-presentation omarchy-refresh-plymouth` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-388 | `update.config.tmux` | Tmux | `omarchy-launch-floating-terminal-with-presentation omarchy-refresh-tmux` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-389 | `update.config.shell` | Shell | `omarchy-launch-floating-terminal-with-presentation omarchy-refresh-shell` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-390 | `update.hardware.audio` | Audio | `omarchy-launch-floating-terminal-with-presentation omarchy-restart-audio` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-391 | `update.hardware.wifi` | Wi-Fi | `omarchy-launch-floating-terminal-with-presentation omarchy-restart-wifi` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-392 | `update.hardware.bluetooth` | Bluetooth | `omarchy-launch-floating-terminal-with-presentation omarchy-restart-bluetooth` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-393 | `update.hardware.trackpad` | Trackpad | `omarchy-launch-floating-terminal-with-presentation omarchy-restart-trackpad` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-394 | `update.password.drive` | Drive Encryption | `omarchy-launch-floating-terminal-with-presentation omarchy-drive-password` |  | default/omarchy/omarchy-menu.jsonc |
| OMA-8-395 | `update.password.user` | User | `omarchy-launch-floating-terminal-with-presentation passwd` |  | default/omarchy/omarchy-menu.jsonc |

## 9. Window manager config and key bindings

### Config load order

| ID | Requirement | Source |
|---|---|---|
| OMA-9-001 | `~/.config/hypr/hyprland.lua` must run `bootstrap.lua`, then `require("default.hypr.omarchy")`. | config/hypr/hyprland.lua |
| OMA-9-002 | It must then load the user files `monitors`, `input`, `bindings`, `looknfeel` and `autostart`, then `default.hypr.toggles`. | config/hypr/hyprland.lua |
| OMA-9-003 | The globals `omarchy_default_bindings=false` and `omarchy_preinstalled_bindings=false` must turn off the default and preinstall bindings. | default/hypr/omarchy.lua |
| OMA-9-004 | The bootstrap must add `~/.local/state`, `~/.config` and `OMARCHY_PATH` to the Lua `package.path`. | default/hypr/bootstrap.lua |

### Environment

| ID | Requirement | Source |
|---|---|---|
| OMA-9-005 | The session must set `XCURSOR_SIZE` and `HYPRCURSOR_SIZE` to 24. | default/hypr/envs.lua |
| OMA-9-006 | The session must set `GDK_BACKEND=wayland,x11,*`, `QT_QPA_PLATFORM=wayland;xcb` and `QT_QPA_PLATFORMTHEME=gtk3`. | default/hypr/envs.lua |
| OMA-9-007 | The session must set `MOZ_ENABLE_WAYLAND=1`, `ELECTRON_OZONE_PLATFORM_HINT=wayland` and `OZONE_PLATFORM=wayland`. | default/hypr/envs.lua |
| OMA-9-008 | The session must set the `XDG_*` desktop variables to `Hyprland` and `XCOMPOSEFILE=~/.XCompose`. | default/hypr/envs.lua |
| OMA-9-009 | XWayland must use `force_zero_scaling`. The ecosystem setting must set `no_update_news`. | default/hypr/envs.lua |
| OMA-9-010 | On NVIDIA GPUs with GSP, the session must set `NVD_BACKEND=direct`. It also sets `LIBVA_DRIVER_NAME` and `__GLX_VENDOR_LIBRARY_NAME` when NVIDIA drives the display. | default/hypr/nvidia.lua |
| OMA-9-011 | On NVIDIA GPUs without GSP, the session must set `NVD_BACKEND=egl`. | default/hypr/nvidia.lua |

### Input

| ID | Requirement | Source |
|---|---|---|
| OMA-9-012 | The keyboard layout must come from `XKBLAYOUT` and `XKBVARIANT` in `/etc/vconsole.conf`. The default is `us`. | default/hypr/input.lua |
| OMA-9-013 | A non-Latin layout must get the prefix `us,` and the option `grp:alts_toggle`. | default/hypr/input.lua |
| OMA-9-014 | `kb_options` must be `compose:caps,shift:both_capslock_cancel`. | default/hypr/input.lua |
| OMA-9-015 | `follow_mouse` must be 1. `repeat_rate` must be 40. `repeat_delay` must be 250. Num Lock must be on. | default/hypr/input.lua |
| OMA-9-016 | The touchpad must use `natural_scroll=false`, `clickfinger_behavior=true` and `scroll_factor=0.4`. | default/hypr/input.lua |
| OMA-9-017 | A key press or mouse move must turn DPMS on. | default/hypr/input.lua |
| OMA-9-018 | The touchpad scroll factor must be 1.5 for Alacritty, kitty and foot, and 0.2 for Ghostty. | default/hypr/input.lua |

### Look and feel

| ID | Requirement | Source |
|---|---|---|
| OMA-9-019 | `gaps_in` must be 5. `gaps_out` must be 10. `border_size` must be 2. | default/hypr/looknfeel.lua |
| OMA-9-020 | The active border must be a 45-degree gradient from `rgba(33ccffee)` to `rgba(00ff99ee)`. | default/hypr/looknfeel.lua |
| OMA-9-021 | The inactive border must be `rgba(595959aa)`. | default/hypr/looknfeel.lua |
| OMA-9-022 | The default layout must be `dwindle`. `rounding` must be 0. | default/hypr/looknfeel.lua |
| OMA-9-023 | Shadows and blur must be off. | default/hypr/looknfeel.lua |
| OMA-9-024 | The workspace animation must be off. The special workspace animation must be `slidevert`. | default/hypr/looknfeel.lua |
| OMA-9-025 | Dwindle must use `preserve_split` and `force_split=2`. | default/hypr/looknfeel.lua |
| OMA-9-026 | The scrolling layout must use `column_width=0.49`. The master layout must use `new_status=master`. | default/hypr/looknfeel.lua |
| OMA-9-027 | The cursor must hide on key press and warp on workspace change. | default/hypr/looknfeel.lua |
| OMA-9-028 | A workspace change must hide the special workspace. | default/hypr/looknfeel.lua |

### Window and layer rules

| ID | Requirement | Source |
|---|---|---|
| OMA-9-029 | Maximize requests must be suppressed. | default/hypr/windows.lua |
| OMA-9-030 | The default opacity must be 0.985 for active windows and 0.96 for inactive windows. | default/hypr/windows.lua |
| OMA-9-031 | The tag `floating-window` must float windows at 875x600. | default/hypr/windows.lua |
| OMA-9-032 | Password managers must have `no_screen_share`. | default/hypr/apps/1password.lua; default/hypr/apps/bitwarden.lua |
| OMA-9-033 | Layer rules must apply to the `omarchy-bar` and menu namespaces. | default/hypr/apps/omarchy-shell.lua |

| ID | App rule file | Source |
|---|---|---|
| OMA-9-034 | `1password.lua` | default/hypr/apps/1password.lua |
| OMA-9-035 | `battlenet.lua` | default/hypr/apps/battlenet.lua |
| OMA-9-036 | `bitwarden.lua` | default/hypr/apps/bitwarden.lua |
| OMA-9-037 | `browser.lua` | default/hypr/apps/browser.lua |
| OMA-9-038 | `davinci-resolve.lua` | default/hypr/apps/davinci-resolve.lua |
| OMA-9-039 | `geforce.lua` | default/hypr/apps/geforce.lua |
| OMA-9-040 | `hermes.lua` | default/hypr/apps/hermes.lua |
| OMA-9-041 | `jetbrains.lua` | default/hypr/apps/jetbrains.lua |
| OMA-9-042 | `localsend.lua` | default/hypr/apps/localsend.lua |
| OMA-9-043 | `moonlight.lua` | default/hypr/apps/moonlight.lua |
| OMA-9-044 | `omarchy-shell.lua` | default/hypr/apps/omarchy-shell.lua |
| OMA-9-045 | `pip.lua` | default/hypr/apps/pip.lua |
| OMA-9-046 | `qemu.lua` | default/hypr/apps/qemu.lua |
| OMA-9-047 | `retroarch.lua` | default/hypr/apps/retroarch.lua |
| OMA-9-048 | `screenshot-selection.lua` | default/hypr/apps/screenshot-selection.lua |
| OMA-9-049 | `steam.lua` | default/hypr/apps/steam.lua |
| OMA-9-050 | `system.lua` | default/hypr/apps/system.lua |
| OMA-9-051 | `telegram.lua` | default/hypr/apps/telegram.lua |
| OMA-9-052 | `terminals.lua` | default/hypr/apps/terminals.lua |
| OMA-9-053 | `webcam-overlay.lua` | default/hypr/apps/webcam-overlay.lua |

### Autostart

| ID | Requirement | Source |
|---|---|---|
| OMA-9-054 | Autostart must import the environment into systemd and D-Bus. | default/hypr/autostart.lua |
| OMA-9-055 | Autostart must run `omarchy-launch-shell`, `omarchy-provision-first-run` and `omarchy-powerprofiles-init`. | default/hypr/autostart.lua |
| OMA-9-056 | Autostart must run `uwsm-app omarchy-hyprland-monitor-watch` and `udiskie --automount --no-notify --no-tray`. | default/hypr/autostart.lua |
| OMA-9-057 | Autostart must run `omarchy-hook post-boot` after 2 s. | default/hypr/autostart.lua |

### User defaults and toggles

| ID | Requirement | Source |
|---|---|---|
| OMA-9-058 | The user `monitors.lua` must set `GDK_SCALE=2` and the monitor `preferred` mode with `auto` scale. | config/hypr/monitors.lua |
| OMA-9-059 | `xdph.conf` must set `custom_picker_binary` to `hyprland-preview-share-picker`. | config/hypr/xdph.conf |
| OMA-9-060 | `hyprsunset.conf` must set the identity profile at 07:00. | config/hypr/hyprsunset.conf |
| OMA-9-061 | Hyprland toggles must be Lua files in `~/.local/state/omarchy/toggles/hypr/`. | default/hypr/toggles.lua |
| OMA-9-062 | The toggles must include `window-no-gaps`, `single-window-aspect-ratio` and `disabled-input-device` for touchpad and touchscreen. | default/hypr/toggles/ |

### Key bindings

The table lists every default key binding. `code:201` is a raw key code. Its key name is not determined. The flag `locked` means the binding works on the lock screen. The flag `repeating` means the binding repeats while the key is held. The condition "Preinstalled bindings enabled" means that `preinstalls-removed` does not exist and `omarchy_preinstalled_bindings` is not false.

| ID | Keys | Description | Action | Flags | Condition | Source |
|---|---|---|---|---|---|---|
| OMA-9-063 | `SUPER + RETURN` | Terminal | `omarchy-launch-terminal` |  |  | default/hypr/bindings/applications.lua |
| OMA-9-064 | `SUPER + SHIFT + RETURN` | Browser | `omarchy-launch-browser` |  |  | default/hypr/bindings/applications.lua |
| OMA-9-065 | `SUPER + SHIFT + F` | File manager | `omarchy-launch-nautilus` |  |  | default/hypr/bindings/applications.lua |
| OMA-9-066 | `SUPER + ALT + SHIFT + F` | File manager (cwd) | `omarchy-launch-nautilus-cwd` |  |  | default/hypr/bindings/applications.lua |
| OMA-9-067 | `SUPER + SHIFT + B` | Browser | `omarchy-launch-browser` |  |  | default/hypr/bindings/applications.lua |
| OMA-9-068 | `SUPER + SHIFT + ALT + B` | Browser (private) | `omarchy-launch-browser --private` |  |  | default/hypr/bindings/applications.lua |
| OMA-9-069 | `SUPER + SHIFT + N` | Editor | `omarchy-launch-editor` |  |  | default/hypr/bindings/applications.lua |
| OMA-9-070 | `SUPER + ALT + RETURN` | Tmux | `omarchy-launch-terminal-tmux` |  | Preinstalled bindings enabled | default/hypr/bindings/applications.lua |
| OMA-9-071 | `SUPER + CTRL + RETURN` | Herdr | `omarchy-launch-terminal-herdr` |  | Preinstalled bindings enabled | default/hypr/bindings/applications.lua |
| OMA-9-072 | `SUPER + SHIFT + M` | Music | `omarchy-launch-spotify` |  | Preinstalled bindings enabled | default/hypr/bindings/applications.lua |
| OMA-9-073 | `SUPER + SHIFT + ALT + M` | Music TUI | `omarchy-launch-or-focus-tui cliamp` |  | Preinstalled bindings enabled | default/hypr/bindings/applications.lua |
| OMA-9-074 | `SUPER + SHIFT + D` | Docker | `omarchy-launch-tui omarchy-launch-docker-tui` |  | Preinstalled bindings enabled | default/hypr/bindings/applications.lua |
| OMA-9-075 | `SUPER + SHIFT + G` | Signal | `omarchy-launch-signal` |  | Preinstalled bindings enabled | default/hypr/bindings/applications.lua |
| OMA-9-076 | `SUPER + SHIFT + O` | Obsidian | `omarchy-launch-or-focus '^obsidian$' 'uwsm-app -- obsidian'` |  | Preinstalled bindings enabled | default/hypr/bindings/applications.lua |
| OMA-9-077 | `SUPER + SHIFT + W` | Omawrite | `uwsm-app -- omawrite` |  | Preinstalled bindings enabled | default/hypr/bindings/applications.lua |
| OMA-9-078 | `SUPER + SHIFT + SLASH` | Passwords | `omarchy-launch-1password` |  | Preinstalled bindings enabled | default/hypr/bindings/applications.lua |
| OMA-9-079 | `SUPER + SHIFT + A` | ChatGPT | `omarchy-launch-webapp https://chatgpt.com` |  | Preinstalled bindings enabled | default/hypr/bindings/applications.lua |
| OMA-9-080 | `SUPER + SHIFT + ALT + A` | Grok | `omarchy-launch-webapp https://grok.com` |  | Preinstalled bindings enabled | default/hypr/bindings/applications.lua |
| OMA-9-081 | `SUPER + SHIFT + C` | Calendar | `omarchy-launch-webapp https://app.hey.com/calendar/weeks/` |  | Preinstalled bindings enabled | default/hypr/bindings/applications.lua |
| OMA-9-082 | `SUPER + SHIFT + E` | Email | `omarchy-launch-webapp https://app.hey.com` |  | Preinstalled bindings enabled | default/hypr/bindings/applications.lua |
| OMA-9-083 | `SUPER + SHIFT + ALT + E` | New email | `omarchy-launch-webapp https://app.hey.com/messages/new?display=standalone&new_window=true` |  | Preinstalled bindings enabled | default/hypr/bindings/applications.lua |
| OMA-9-084 | `SUPER + SHIFT + Y` | YouTube | `omarchy-launch-webapp https://youtube.com/` |  | Preinstalled bindings enabled | default/hypr/bindings/applications.lua |
| OMA-9-085 | `SUPER + SHIFT + ALT + G` | WhatsApp | `omarchy-launch-or-focus-webapp 'WhatsApp' https://web.whatsapp.com/` |  | Preinstalled bindings enabled | default/hypr/bindings/applications.lua |
| OMA-9-086 | `SUPER + SHIFT + CTRL + G` | Google Messages | `omarchy-launch-or-focus-webapp 'Google Messages' https://messages.google.com/web/conversations` |  | Preinstalled bindings enabled | default/hypr/bindings/applications.lua |
| OMA-9-087 | `SUPER + SHIFT + P` | Google Photos | `omarchy-launch-or-focus-webapp 'Google Photos' https://photos.google.com/` |  | Preinstalled bindings enabled | default/hypr/bindings/applications.lua |
| OMA-9-088 | `SUPER + SHIFT + S` | Google Maps | `omarchy-launch-or-focus-webapp 'Google Maps' https://maps.google.com/` |  | Preinstalled bindings enabled | default/hypr/bindings/applications.lua |
| OMA-9-089 | `SUPER + SHIFT + X` | X | `omarchy-launch-webapp https://x.com/` |  | Preinstalled bindings enabled | default/hypr/bindings/applications.lua |
| OMA-9-090 | `SUPER + SHIFT + ALT + X` | X Post | `omarchy-launch-webapp https://x.com/compose/post` |  | Preinstalled bindings enabled | default/hypr/bindings/applications.lua |
| OMA-9-091 | `SUPER + C` | Universal copy | `universal_clipboard_shortcut("CTRL", "C", "CTRL", "Insert")` |  |  | default/hypr/bindings/clipboard.lua |
| OMA-9-092 | `SUPER + V` | Universal paste | `universal_clipboard_shortcut("CTRL", "V", "SHIFT", "Insert")` |  |  | default/hypr/bindings/clipboard.lua |
| OMA-9-093 | `SUPER + X` | Universal cut | `send_shortcut_once("CTRL", "X")` |  |  | default/hypr/bindings/clipboard.lua |
| OMA-9-094 | `SUPER + CTRL + V` | Clipboard manager | `omarchy-shell shell toggle omarchy.clipboard` |  |  | default/hypr/bindings/clipboard.lua |
| OMA-9-095 | `XF86AudioRaiseVolume` | Volume up | `omarchy-audio-output-volume raise` | locked, repeating |  | default/hypr/bindings/media.lua |
| OMA-9-096 | `XF86AudioLowerVolume` | Volume down | `omarchy-audio-output-volume lower` | locked, repeating |  | default/hypr/bindings/media.lua |
| OMA-9-097 | `XF86AudioMute` | Mute | `omarchy-audio-output-volume mute-toggle` | locked |  | default/hypr/bindings/media.lua |
| OMA-9-098 | `XF86AudioMicMute` | Mute microphone | `omarchy-audio-input-mute` | locked |  | default/hypr/bindings/media.lua |
| OMA-9-099 | `XF86MonBrightnessUp` | Brightness up | `omarchy-brightness-display +5%` | locked, repeating |  | default/hypr/bindings/media.lua |
| OMA-9-100 | `XF86MonBrightnessDown` | Brightness down | `omarchy-brightness-display 5%-` | locked, repeating |  | default/hypr/bindings/media.lua |
| OMA-9-101 | `SHIFT + XF86MonBrightnessUp` | Brightness maximum | `omarchy-brightness-display 100%` | locked, repeating |  | default/hypr/bindings/media.lua |
| OMA-9-102 | `SHIFT + XF86MonBrightnessDown` | Brightness minimum | `omarchy-brightness-display 1%` | locked, repeating |  | default/hypr/bindings/media.lua |
| OMA-9-103 | `XF86KbdBrightnessUp` | Keyboard brightness up | `omarchy-brightness-keyboard up` | locked, repeating |  | default/hypr/bindings/media.lua |
| OMA-9-104 | `XF86KbdBrightnessDown` | Keyboard brightness down | `omarchy-brightness-keyboard down` | locked, repeating |  | default/hypr/bindings/media.lua |
| OMA-9-105 | `XF86KbdLightOnOff` | Keyboard backlight cycle | `omarchy-brightness-keyboard cycle` | locked |  | default/hypr/bindings/media.lua |
| OMA-9-106 | `XF86TouchpadToggle` | Toggle touchpad | `omarchy-toggle-touchpad` | locked |  | default/hypr/bindings/media.lua |
| OMA-9-107 | `XF86TouchpadOn` | Enable touchpad | `omarchy-toggle-touchpad on` | locked |  | default/hypr/bindings/media.lua |
| OMA-9-108 | `XF86TouchpadOff` | Disable touchpad | `omarchy-toggle-touchpad off` | locked |  | default/hypr/bindings/media.lua |
| OMA-9-109 | `ALT + XF86AudioRaiseVolume` | Volume up precise | `omarchy-audio-output-volume +1` | locked, repeating |  | default/hypr/bindings/media.lua |
| OMA-9-110 | `ALT + XF86AudioLowerVolume` | Volume down precise | `omarchy-audio-output-volume -1` | locked, repeating |  | default/hypr/bindings/media.lua |
| OMA-9-111 | `ALT + XF86MonBrightnessUp` | Brightness up precise | `omarchy-brightness-display +1%` | locked, repeating |  | default/hypr/bindings/media.lua |
| OMA-9-112 | `ALT + XF86MonBrightnessDown` | Brightness down precise | `omarchy-brightness-display 1%-` | locked, repeating |  | default/hypr/bindings/media.lua |
| OMA-9-113 | `XF86AudioNext` | Next track | `omarchy-shell media next` | locked |  | default/hypr/bindings/media.lua |
| OMA-9-114 | `ALT + XF86AudioPlay` | Next track | `omarchy-shell media next` | locked |  | default/hypr/bindings/media.lua |
| OMA-9-115 | `XF86AudioPause` | Pause | `omarchy-shell media playPause` | locked |  | default/hypr/bindings/media.lua |
| OMA-9-116 | `XF86AudioPlay` | Play | `omarchy-shell media playPause` | locked |  | default/hypr/bindings/media.lua |
| OMA-9-117 | `XF86AudioPrev` | Previous track | `omarchy-shell media previous` | locked |  | default/hypr/bindings/media.lua |
| OMA-9-118 | `ALT + SHIFT + XF86AudioPlay` | Previous track | `omarchy-shell media previous` | locked |  | default/hypr/bindings/media.lua |
| OMA-9-119 | `XF86Eject` | Eject media | `eject` | locked |  | default/hypr/bindings/media.lua |
| OMA-9-120 | `SHIFT + XF86AudioMute` | Switch audio output | `omarchy-audio-output-switch` | locked |  | default/hypr/bindings/media.lua |
| OMA-9-121 | `SHIFT + XF86AudioPause` | Switch media source | `omarchy-audio-source-switch` | locked |  | default/hypr/bindings/media.lua |
| OMA-9-122 | `SHIFT + XF86AudioPlay` | Switch media source | `omarchy-audio-source-switch` | locked |  | default/hypr/bindings/media.lua |
| OMA-9-123 | `SUPER + W` | Close window | `hl.dsp.window.close()` |  |  | default/hypr/bindings/tiling.lua |
| OMA-9-124 | `CTRL + ALT + DELETE` | Close all windows | `omarchy-hyprland-window-close-all` |  |  | default/hypr/bindings/tiling.lua |
| OMA-9-125 | `SUPER + J` | Toggle window split | `hl.dsp.layout("togglesplit")` |  |  | default/hypr/bindings/tiling.lua |
| OMA-9-126 | `SUPER + P` | Pseudo window | `hl.dsp.window.pseudo()` |  |  | default/hypr/bindings/tiling.lua |
| OMA-9-127 | `SUPER + T` | Toggle window floating/tiling | `hl.dsp.window.float({ action = "toggle" })` |  |  | default/hypr/bindings/tiling.lua |
| OMA-9-128 | `SUPER + F` | Full screen | `hl.dsp.window.fullscreen({ mode = "fullscreen" })` |  |  | default/hypr/bindings/tiling.lua |
| OMA-9-129 | `SUPER + CTRL + F` | Tiled full screen | `omarchy-hyprland-window-tiled-fullscreen-toggle` |  |  | default/hypr/bindings/tiling.lua |
| OMA-9-130 | `SUPER + ALT + F` | Full width | `hl.dsp.window.fullscreen({ mode = "maximized" })` |  |  | default/hypr/bindings/tiling.lua |
| OMA-9-131 | `SUPER + O` | Pop window out (float & pin) | `omarchy-hyprland-window-pop` |  |  | default/hypr/bindings/tiling.lua |
| OMA-9-132 | `SUPER + ALT + Home` | Save window width | `omarchy-hyprland-window-width save` |  |  | default/hypr/bindings/tiling.lua |
| OMA-9-133 | `SUPER + Home` | Restore window width | `omarchy-hyprland-window-width restore` |  |  | default/hypr/bindings/tiling.lua |
| OMA-9-134 | `SUPER + L` | Toggle workspace layout | `omarchy-hyprland-workspace-layout-toggle` |  |  | default/hypr/bindings/tiling.lua |
| OMA-9-135 | `SUPER + LEFT` | Focus on left window | `hl.dsp.focus({ direction = "l" })` |  |  | default/hypr/bindings/tiling.lua |
| OMA-9-136 | `SUPER + RIGHT` | Focus on right window | `hl.dsp.focus({ direction = "r" })` |  |  | default/hypr/bindings/tiling.lua |
| OMA-9-137 | `SUPER + UP` | Focus on above window | `hl.dsp.focus({ direction = "u" })` |  |  | default/hypr/bindings/tiling.lua |
| OMA-9-138 | `SUPER + DOWN` | Focus on below window | `hl.dsp.focus({ direction = "d" })` |  |  | default/hypr/bindings/tiling.lua |
| OMA-9-139 | `SUPER + 1` | Switch to workspace 1 | `hl.dsp.focus({ workspace = "1" })` |  |  | default/hypr/bindings/tiling.lua |
| OMA-9-140 | `SUPER + SHIFT + 1` | Move window to workspace 1 | `hl.dsp.window.move({ workspace = "1" })` |  |  | default/hypr/bindings/tiling.lua |
| OMA-9-141 | `SUPER + SHIFT + ALT + 1` | Move window silently to workspace 1 | `hl.dsp.window.move({ workspace = "1", follow = false })` |  |  | default/hypr/bindings/tiling.lua |
| OMA-9-142 | `SUPER + 2` | Switch to workspace 2 | `hl.dsp.focus({ workspace = "2" })` |  |  | default/hypr/bindings/tiling.lua |
| OMA-9-143 | `SUPER + SHIFT + 2` | Move window to workspace 2 | `hl.dsp.window.move({ workspace = "2" })` |  |  | default/hypr/bindings/tiling.lua |
| OMA-9-144 | `SUPER + SHIFT + ALT + 2` | Move window silently to workspace 2 | `hl.dsp.window.move({ workspace = "2", follow = false })` |  |  | default/hypr/bindings/tiling.lua |
| OMA-9-145 | `SUPER + 3` | Switch to workspace 3 | `hl.dsp.focus({ workspace = "3" })` |  |  | default/hypr/bindings/tiling.lua |
| OMA-9-146 | `SUPER + SHIFT + 3` | Move window to workspace 3 | `hl.dsp.window.move({ workspace = "3" })` |  |  | default/hypr/bindings/tiling.lua |
| OMA-9-147 | `SUPER + SHIFT + ALT + 3` | Move window silently to workspace 3 | `hl.dsp.window.move({ workspace = "3", follow = false })` |  |  | default/hypr/bindings/tiling.lua |
| OMA-9-148 | `SUPER + 4` | Switch to workspace 4 | `hl.dsp.focus({ workspace = "4" })` |  |  | default/hypr/bindings/tiling.lua |
| OMA-9-149 | `SUPER + SHIFT + 4` | Move window to workspace 4 | `hl.dsp.window.move({ workspace = "4" })` |  |  | default/hypr/bindings/tiling.lua |
| OMA-9-150 | `SUPER + SHIFT + ALT + 4` | Move window silently to workspace 4 | `hl.dsp.window.move({ workspace = "4", follow = false })` |  |  | default/hypr/bindings/tiling.lua |
| OMA-9-151 | `SUPER + 5` | Switch to workspace 5 | `hl.dsp.focus({ workspace = "5" })` |  |  | default/hypr/bindings/tiling.lua |
| OMA-9-152 | `SUPER + SHIFT + 5` | Move window to workspace 5 | `hl.dsp.window.move({ workspace = "5" })` |  |  | default/hypr/bindings/tiling.lua |
| OMA-9-153 | `SUPER + SHIFT + ALT + 5` | Move window silently to workspace 5 | `hl.dsp.window.move({ workspace = "5", follow = false })` |  |  | default/hypr/bindings/tiling.lua |
| OMA-9-154 | `SUPER + 6` | Switch to workspace 6 | `hl.dsp.focus({ workspace = "6" })` |  |  | default/hypr/bindings/tiling.lua |
| OMA-9-155 | `SUPER + SHIFT + 6` | Move window to workspace 6 | `hl.dsp.window.move({ workspace = "6" })` |  |  | default/hypr/bindings/tiling.lua |
| OMA-9-156 | `SUPER + SHIFT + ALT + 6` | Move window silently to workspace 6 | `hl.dsp.window.move({ workspace = "6", follow = false })` |  |  | default/hypr/bindings/tiling.lua |
| OMA-9-157 | `SUPER + 7` | Switch to workspace 7 | `hl.dsp.focus({ workspace = "7" })` |  |  | default/hypr/bindings/tiling.lua |
| OMA-9-158 | `SUPER + SHIFT + 7` | Move window to workspace 7 | `hl.dsp.window.move({ workspace = "7" })` |  |  | default/hypr/bindings/tiling.lua |
| OMA-9-159 | `SUPER + SHIFT + ALT + 7` | Move window silently to workspace 7 | `hl.dsp.window.move({ workspace = "7", follow = false })` |  |  | default/hypr/bindings/tiling.lua |
| OMA-9-160 | `SUPER + 8` | Switch to workspace 8 | `hl.dsp.focus({ workspace = "8" })` |  |  | default/hypr/bindings/tiling.lua |
| OMA-9-161 | `SUPER + SHIFT + 8` | Move window to workspace 8 | `hl.dsp.window.move({ workspace = "8" })` |  |  | default/hypr/bindings/tiling.lua |
| OMA-9-162 | `SUPER + SHIFT + ALT + 8` | Move window silently to workspace 8 | `hl.dsp.window.move({ workspace = "8", follow = false })` |  |  | default/hypr/bindings/tiling.lua |
| OMA-9-163 | `SUPER + 9` | Switch to workspace 9 | `hl.dsp.focus({ workspace = "9" })` |  |  | default/hypr/bindings/tiling.lua |
| OMA-9-164 | `SUPER + SHIFT + 9` | Move window to workspace 9 | `hl.dsp.window.move({ workspace = "9" })` |  |  | default/hypr/bindings/tiling.lua |
| OMA-9-165 | `SUPER + SHIFT + ALT + 9` | Move window silently to workspace 9 | `hl.dsp.window.move({ workspace = "9", follow = false })` |  |  | default/hypr/bindings/tiling.lua |
| OMA-9-166 | `SUPER + 0` | Switch to workspace 10 | `hl.dsp.focus({ workspace = "10" })` |  |  | default/hypr/bindings/tiling.lua |
| OMA-9-167 | `SUPER + SHIFT + 0` | Move window to workspace 10 | `hl.dsp.window.move({ workspace = "10" })` |  |  | default/hypr/bindings/tiling.lua |
| OMA-9-168 | `SUPER + SHIFT + ALT + 0` | Move window silently to workspace 10 | `hl.dsp.window.move({ workspace = "10", follow = false })` |  |  | default/hypr/bindings/tiling.lua |
| OMA-9-169 | `SUPER + S` | Toggle scratchpad | `hl.dsp.workspace.toggle_special("scratchpad")` |  |  | default/hypr/bindings/tiling.lua |
| OMA-9-170 | `SUPER + ALT + S` | Move window to scratchpad | `hl.dsp.window.move({ workspace = "special:scratchpad", follow = false })` |  |  | default/hypr/bindings/tiling.lua |
| OMA-9-171 | `SUPER + TAB` | Next workspace | `hl.dsp.focus({ workspace = "e+1" })` |  |  | default/hypr/bindings/tiling.lua |
| OMA-9-172 | `SUPER + SHIFT + TAB` | Previous workspace | `hl.dsp.focus({ workspace = "e-1" })` |  |  | default/hypr/bindings/tiling.lua |
| OMA-9-173 | `SUPER + CTRL + TAB` | Former workspace | `hl.dsp.focus({ workspace = "previous" })` |  |  | default/hypr/bindings/tiling.lua |
| OMA-9-174 | `SUPER + SHIFT + ALT + LEFT` | Move workspace to left monitor | `hl.dsp.workspace.move({ monitor = "l" })` |  |  | default/hypr/bindings/tiling.lua |
| OMA-9-175 | `SUPER + SHIFT + ALT + RIGHT` | Move workspace to right monitor | `hl.dsp.workspace.move({ monitor = "r" })` |  |  | default/hypr/bindings/tiling.lua |
| OMA-9-176 | `SUPER + SHIFT + ALT + UP` | Move workspace to up monitor | `hl.dsp.workspace.move({ monitor = "u" })` |  |  | default/hypr/bindings/tiling.lua |
| OMA-9-177 | `SUPER + SHIFT + ALT + DOWN` | Move workspace to down monitor | `hl.dsp.workspace.move({ monitor = "d" })` |  |  | default/hypr/bindings/tiling.lua |
| OMA-9-178 | `SUPER + SHIFT + LEFT` | Swap window to the left | `hl.dsp.window.swap({ direction = "l" })` |  |  | default/hypr/bindings/tiling.lua |
| OMA-9-179 | `SUPER + SHIFT + RIGHT` | Swap window to the right | `hl.dsp.window.swap({ direction = "r" })` |  |  | default/hypr/bindings/tiling.lua |
| OMA-9-180 | `SUPER + SHIFT + UP` | Swap window up | `hl.dsp.window.swap({ direction = "u" })` |  |  | default/hypr/bindings/tiling.lua |
| OMA-9-181 | `SUPER + SHIFT + DOWN` | Swap window down | `hl.dsp.window.swap({ direction = "d" })` |  |  | default/hypr/bindings/tiling.lua |
| OMA-9-182 | `ALT + TAB` | Focus on next window | `hl.dsp.window.cycle_next()` |  |  | default/hypr/bindings/tiling.lua |
| OMA-9-183 | `ALT + SHIFT + TAB` | Focus on previous window | `hl.dsp.window.cycle_next({ next = false })` |  |  | default/hypr/bindings/tiling.lua |
| OMA-9-184 | `ALT + TAB` | Reveal active window on top | `hl.dsp.window.bring_to_top()` |  |  | default/hypr/bindings/tiling.lua |
| OMA-9-185 | `ALT + SHIFT + TAB` | Reveal active window on top | `hl.dsp.window.bring_to_top()` |  |  | default/hypr/bindings/tiling.lua |
| OMA-9-186 | `CTRL + ALT + TAB` | Focus on next monitor | `hl.dsp.focus({ monitor = "+1" })` |  |  | default/hypr/bindings/tiling.lua |
| OMA-9-187 | `CTRL + ALT + SHIFT + TAB` | Focus on previous monitor | `hl.dsp.focus({ monitor = "-1" })` |  |  | default/hypr/bindings/tiling.lua |
| OMA-9-188 | `SUPER + MINUS` | Expand window left | `hl.dsp.window.resize({ x = -100, y = 0, relative = true })` |  |  | default/hypr/bindings/tiling.lua |
| OMA-9-189 | `SUPER + EQUAL` | Shrink window left | `hl.dsp.window.resize({ x = 100, y = 0, relative = true })` |  |  | default/hypr/bindings/tiling.lua |
| OMA-9-190 | `SUPER + SHIFT + MINUS` | Shrink window up | `hl.dsp.window.resize({ x = 0, y = -100, relative = true })` |  |  | default/hypr/bindings/tiling.lua |
| OMA-9-191 | `SUPER + SHIFT + EQUAL` | Expand window down | `hl.dsp.window.resize({ x = 0, y = 100, relative = true })` |  |  | default/hypr/bindings/tiling.lua |
| OMA-9-192 | `SUPER + ALT + MINUS` | Expand window left a little | `hl.dsp.window.resize({ x = -25, y = 0, relative = true })` |  |  | default/hypr/bindings/tiling.lua |
| OMA-9-193 | `SUPER + ALT + EQUAL` | Shrink window left a little | `hl.dsp.window.resize({ x = 25, y = 0, relative = true })` |  |  | default/hypr/bindings/tiling.lua |
| OMA-9-194 | `SUPER + SHIFT + ALT + MINUS` | Shrink window up a little | `hl.dsp.window.resize({ x = 0, y = -25, relative = true })` |  |  | default/hypr/bindings/tiling.lua |
| OMA-9-195 | `SUPER + SHIFT + ALT + EQUAL` | Expand window down a little | `hl.dsp.window.resize({ x = 0, y = 25, relative = true })` |  |  | default/hypr/bindings/tiling.lua |
| OMA-9-196 | `SUPER + CTRL + MINUS` | Expand window left a lot | `hl.dsp.window.resize({ x = -300, y = 0, relative = true })` |  |  | default/hypr/bindings/tiling.lua |
| OMA-9-197 | `SUPER + CTRL + EQUAL` | Shrink window left a lot | `hl.dsp.window.resize({ x = 300, y = 0, relative = true })` |  |  | default/hypr/bindings/tiling.lua |
| OMA-9-198 | `SUPER + CTRL + SHIFT + MINUS` | Shrink window up a lot | `hl.dsp.window.resize({ x = 0, y = -300, relative = true })` |  |  | default/hypr/bindings/tiling.lua |
| OMA-9-199 | `SUPER + CTRL + SHIFT + EQUAL` | Expand window down a lot | `hl.dsp.window.resize({ x = 0, y = 300, relative = true })` |  |  | default/hypr/bindings/tiling.lua |
| OMA-9-200 | `SUPER + mouse_down` | Scroll active workspace forward | `hl.dsp.focus({ workspace = "e+1" })` |  |  | default/hypr/bindings/tiling.lua |
| OMA-9-201 | `SUPER + mouse_up` | Scroll active workspace backward | `hl.dsp.focus({ workspace = "e-1" })` |  |  | default/hypr/bindings/tiling.lua |
| OMA-9-202 | `SUPER + mouse:272` | Move window | `hl.dsp.window.drag()` | mouse |  | default/hypr/bindings/tiling.lua |
| OMA-9-203 | `SUPER + mouse:273` | Resize window | `hl.dsp.window.resize()` | mouse |  | default/hypr/bindings/tiling.lua |
| OMA-9-204 | `SUPER + G` | Toggle window grouping | `hl.dsp.group.toggle()` |  |  | default/hypr/bindings/tiling.lua |
| OMA-9-205 | `SUPER + ALT + G` | Move active window out of group | `hl.dsp.window.move({ out_of_group = true })` |  |  | default/hypr/bindings/tiling.lua |
| OMA-9-206 | `SUPER + ALT + LEFT` | Move window to group on left | `hl.dsp.window.move({ into_group = "l" })` |  |  | default/hypr/bindings/tiling.lua |
| OMA-9-207 | `SUPER + ALT + RIGHT` | Move window to group on right | `hl.dsp.window.move({ into_group = "r" })` |  |  | default/hypr/bindings/tiling.lua |
| OMA-9-208 | `SUPER + ALT + UP` | Move window to group on top | `hl.dsp.window.move({ into_group = "u" })` |  |  | default/hypr/bindings/tiling.lua |
| OMA-9-209 | `SUPER + ALT + DOWN` | Move window to group on bottom | `hl.dsp.window.move({ into_group = "d" })` |  |  | default/hypr/bindings/tiling.lua |
| OMA-9-210 | `SUPER + ALT + TAB` | Next window in group | `hl.dsp.group.next()` |  |  | default/hypr/bindings/tiling.lua |
| OMA-9-211 | `SUPER + ALT + SHIFT + TAB` | Previous window in group | `hl.dsp.group.prev()` |  |  | default/hypr/bindings/tiling.lua |
| OMA-9-212 | `SUPER + CTRL + LEFT` | Move grouped window focus left | `hl.dsp.group.prev()` |  |  | default/hypr/bindings/tiling.lua |
| OMA-9-213 | `SUPER + CTRL + RIGHT` | Move grouped window focus right | `hl.dsp.group.next()` |  |  | default/hypr/bindings/tiling.lua |
| OMA-9-214 | `SUPER + ALT + mouse_down` | Next window in group | `hl.dsp.group.next()` |  |  | default/hypr/bindings/tiling.lua |
| OMA-9-215 | `SUPER + ALT + mouse_up` | Previous window in group | `hl.dsp.group.prev()` |  |  | default/hypr/bindings/tiling.lua |
| OMA-9-216 | `SUPER + SLASH` | Monitor scaling up | `omarchy-hyprland-monitor-scaling up` |  |  | default/hypr/bindings/tiling.lua |
| OMA-9-217 | `SUPER + ALT + SLASH` | Monitor scaling down | `omarchy-hyprland-monitor-scaling down` |  |  | default/hypr/bindings/tiling.lua |
| OMA-9-218 | `SUPER + ALT + 1` | Switch to group window 1 | `hl.dsp.group.active({ index = 1 })` |  |  | default/hypr/bindings/tiling.lua |
| OMA-9-219 | `SUPER + ALT + 2` | Switch to group window 2 | `hl.dsp.group.active({ index = 2 })` |  |  | default/hypr/bindings/tiling.lua |
| OMA-9-220 | `SUPER + ALT + 3` | Switch to group window 3 | `hl.dsp.group.active({ index = 3 })` |  |  | default/hypr/bindings/tiling.lua |
| OMA-9-221 | `SUPER + ALT + 4` | Switch to group window 4 | `hl.dsp.group.active({ index = 4 })` |  |  | default/hypr/bindings/tiling.lua |
| OMA-9-222 | `SUPER + ALT + 5` | Switch to group window 5 | `hl.dsp.group.active({ index = 5 })` |  |  | default/hypr/bindings/tiling.lua |
| OMA-9-223 | `SUPER + SPACE` | Omarchy menu | `omarchy-menu toggle` |  |  | default/hypr/bindings/utilities.lua |
| OMA-9-224 | `SUPER + ALT + SPACE` | Apps menu | `omarchy-menu toggle apps` |  |  | default/hypr/bindings/utilities.lua |
| OMA-9-225 | `SUPER + CTRL + E` | Emojis | `omarchy-shell shell toggle omarchy.emojis` |  |  | default/hypr/bindings/utilities.lua |
| OMA-9-226 | `SUPER + CTRL + C` | Capture menu | `omarchy-menu toggle capture` |  |  | default/hypr/bindings/utilities.lua |
| OMA-9-227 | `SUPER + CTRL + O` | Toggle menu | `omarchy-menu toggle toggle` |  |  | default/hypr/bindings/utilities.lua |
| OMA-9-228 | `SUPER + CTRL + H` | Hardware menu | `omarchy-menu toggle hardware` |  |  | default/hypr/bindings/utilities.lua |
| OMA-9-229 | `SUPER + SHIFT + code:201` | Omarchy menu | `omarchy-menu toggle root` |  |  | default/hypr/bindings/utilities.lua |
| OMA-9-230 | `SUPER + ESCAPE` | System menu | `omarchy-menu toggle system` |  |  | default/hypr/bindings/utilities.lua |
| OMA-9-231 | `XF86PowerOff` | Power menu | `omarchy-menu toggle system` | locked |  | default/hypr/bindings/utilities.lua |
| OMA-9-232 | `SUPER + K` | Keybindings | `omarchy-menu-keybindings` |  |  | default/hypr/bindings/utilities.lua |
| OMA-9-233 | `SUPER + ALT + K` | Tmux keybindings | `omarchy-menu-tmux-keybindings` |  |  | default/hypr/bindings/utilities.lua |
| OMA-9-234 | `SUPER + CTRL + K` | Herdr keybindings | `omarchy-menu-herdr-keybindings` |  |  | default/hypr/bindings/utilities.lua |
| OMA-9-235 | `SUPER + CTRL + Q` | Calculator | `omacalc` |  |  | default/hypr/bindings/utilities.lua |
| OMA-9-236 | `XF86Calculator` | Calculator | `omacalc` |  |  | default/hypr/bindings/utilities.lua |
| OMA-9-237 | `SUPER + SHIFT + SPACE` | Toggle top bar | `omarchy-toggle-bar` |  |  | default/hypr/bindings/utilities.lua |
| OMA-9-238 | `SUPER + CTRL + SPACE` | Background switcher | `omarchy-menu toggle background` |  |  | default/hypr/bindings/utilities.lua |
| OMA-9-239 | `SUPER + SHIFT + CTRL + SPACE` | Theme menu | `omarchy-menu toggle theme` |  |  | default/hypr/bindings/utilities.lua |
| OMA-9-240 | `SUPER + BACKSPACE` | Toggle window transparency | `omarchy-hyprland-window-transparency-toggle` |  |  | default/hypr/bindings/utilities.lua |
| OMA-9-241 | `SUPER + SHIFT + BACKSPACE` | Toggle window gaps | `omarchy-hyprland-window-gaps-toggle` |  |  | default/hypr/bindings/utilities.lua |
| OMA-9-242 | `SUPER + CTRL + BACKSPACE` | Toggle single-window square aspect | `omarchy-hyprland-window-single-square-aspect-toggle` |  |  | default/hypr/bindings/utilities.lua |
| OMA-9-243 | `SUPER + comma` | Dismiss last notification | `omarchy-shell notifications dismissOne` |  |  | default/hypr/bindings/utilities.lua |
| OMA-9-244 | `SUPER + SHIFT + comma` | Dismiss all notifications | `omarchy-shell notifications dismissAll` |  |  | default/hypr/bindings/utilities.lua |
| OMA-9-245 | `SUPER + CTRL + comma` | Toggle silencing notifications | `omarchy-toggle-notification-silencing` |  |  | default/hypr/bindings/utilities.lua |
| OMA-9-246 | `SUPER + ALT + comma` | Invoke last notification | `omarchy-shell notifications invokeLast` |  |  | default/hypr/bindings/utilities.lua |
| OMA-9-247 | `SUPER + SHIFT + ALT + comma` | Open notification history | `omarchy-shell notifications showHistory` |  |  | default/hypr/bindings/utilities.lua |
| OMA-9-248 | `SUPER + CTRL + I` | Toggle locking on idle | `omarchy-toggle-idle` |  |  | default/hypr/bindings/utilities.lua |
| OMA-9-249 | `SUPER + CTRL + N` | Toggle nightlight | `omarchy-toggle-nightlight` |  |  | default/hypr/bindings/utilities.lua |
| OMA-9-250 | `SUPER + CTRL + Delete` | Toggle laptop display | `omarchy-hyprland-monitor-internal toggle` |  |  | default/hypr/bindings/utilities.lua |
| OMA-9-251 | `SUPER + CTRL + ALT + Delete` | Toggle laptop display mirroring | `omarchy-hyprland-monitor-internal-mirror toggle` |  |  | default/hypr/bindings/utilities.lua |
| OMA-9-252 | `switch:on:Lid Switch` | (no description) | `omarchy-system-lid-close` | locked |  | default/hypr/bindings/utilities.lua |
| OMA-9-253 | `switch:off:Lid Switch` | (no description) | `omarchy-hyprland-monitor-clamshell` | locked |  | default/hypr/bindings/utilities.lua |
| OMA-9-254 | `PRINT` | Screenshot | `omarchy-capture-screenshot` |  |  | default/hypr/bindings/utilities.lua |
| OMA-9-255 | `ALT + PRINT` | Screenrecording | `omarchy-capture-screenrecording --stop-recording \|\| omarchy-menu toggle trigger.capture.screenrecord` |  |  | default/hypr/bindings/utilities.lua |
| OMA-9-256 | `SUPER + ALT + BRACKETLEFT` | Make webcam overlay smaller | `omarchy-capture-webcam-resize smaller` |  |  | default/hypr/bindings/utilities.lua |
| OMA-9-257 | `SUPER + ALT + BRACKETRIGHT` | Make webcam overlay larger | `omarchy-capture-webcam-resize larger` |  |  | default/hypr/bindings/utilities.lua |
| OMA-9-258 | `SUPER + PRINT` | Color picker | `pkill hyprpicker \|\| hyprpicker -a` |  |  | default/hypr/bindings/utilities.lua |
| OMA-9-259 | `SUPER + CTRL + PRINT` | Extract text (OCR) from screenshot | `omarchy-capture-text` |  |  | default/hypr/bindings/utilities.lua |
| OMA-9-260 | `SUPER + CTRL + S` | Share | `omarchy-menu toggle share` |  |  | default/hypr/bindings/utilities.lua |
| OMA-9-261 | `SUPER + CTRL + PERIOD` | Transcode | `omarchy-transcode` |  |  | default/hypr/bindings/utilities.lua |
| OMA-9-262 | `SUPER + CTRL + R` | Set reminder | `omarchy-menu toggle reminder-set` |  |  | default/hypr/bindings/utilities.lua |
| OMA-9-263 | `SUPER + CTRL + ALT + R` | Show reminders | `omarchy-reminder show` |  |  | default/hypr/bindings/utilities.lua |
| OMA-9-264 | `SUPER + SHIFT + CTRL + R` | Clear reminders | `omarchy-reminder clear` |  |  | default/hypr/bindings/utilities.lua |
| OMA-9-265 | `SUPER + CTRL + ALT + T` | Show time | `omarchy-notification-time` |  |  | default/hypr/bindings/utilities.lua |
| OMA-9-266 | `SUPER + CTRL + ALT + B` | Show battery remaining | `omarchy-notification-battery` |  |  | default/hypr/bindings/utilities.lua |
| OMA-9-267 | `SUPER + CTRL + ALT + W` | Toggle weather | `omarchy-notification-weather` |  |  | default/hypr/bindings/utilities.lua |
| OMA-9-268 | `SUPER + SHIFT + CTRL + A` | Agent | `omarchy-agent --pick` |  |  | default/hypr/bindings/utilities.lua |
| OMA-9-269 | `SUPER + CTRL + A` | Audio | `omarchy-shell shell toggle omarchy.audio` |  |  | default/hypr/bindings/utilities.lua |
| OMA-9-270 | `SUPER + CTRL + B` | Bluetooth | `omarchy-shell shell toggle omarchy.bluetooth` |  |  | default/hypr/bindings/utilities.lua |
| OMA-9-271 | `SUPER + CTRL + D` | Display | `omarchy-shell shell toggle omarchy.monitor` |  |  | default/hypr/bindings/utilities.lua |
| OMA-9-272 | `SUPER + CTRL + ALT + D` | Calendar | `omarchy-shell shell toggle omarchy.clock` |  |  | default/hypr/bindings/utilities.lua |
| OMA-9-273 | `SUPER + CTRL + W` | Network | `omarchy-shell shell toggle omarchy.network` |  |  | default/hypr/bindings/utilities.lua |
| OMA-9-274 | `SUPER + CTRL + P` | Power | `omarchy-shell shell toggle omarchy.power` |  |  | default/hypr/bindings/utilities.lua |
| OMA-9-275 | `SUPER + CTRL + T` | Activity | `omarchy-launch-tui btop` |  |  | default/hypr/bindings/utilities.lua |
| OMA-9-276 | `SUPER + CTRL + 1` | Bar panel 1 | `omarchy-shell -q shell togglePanelAt right 1` |  |  | default/hypr/bindings/utilities.lua |
| OMA-9-277 | `SUPER + CTRL + 2` | Bar panel 2 | `omarchy-shell -q shell togglePanelAt right 2` |  |  | default/hypr/bindings/utilities.lua |
| OMA-9-278 | `SUPER + CTRL + 3` | Bar panel 3 | `omarchy-shell -q shell togglePanelAt right 3` |  |  | default/hypr/bindings/utilities.lua |
| OMA-9-279 | `SUPER + CTRL + 4` | Bar panel 4 | `omarchy-shell -q shell togglePanelAt right 4` |  |  | default/hypr/bindings/utilities.lua |
| OMA-9-280 | `SUPER + CTRL + 5` | Bar panel 5 | `omarchy-shell -q shell togglePanelAt right 5` |  |  | default/hypr/bindings/utilities.lua |
| OMA-9-281 | `SUPER + CTRL + 6` | Bar panel 6 | `omarchy-shell -q shell togglePanelAt right 6` |  |  | default/hypr/bindings/utilities.lua |
| OMA-9-282 | `SUPER + CTRL + 7` | Bar panel 7 | `omarchy-shell -q shell togglePanelAt right 7` |  |  | default/hypr/bindings/utilities.lua |
| OMA-9-283 | `SUPER + CTRL + 8` | Bar panel 8 | `omarchy-shell -q shell togglePanelAt right 8` |  |  | default/hypr/bindings/utilities.lua |
| OMA-9-284 | `SUPER + CTRL + 9` | Bar panel 9 | `omarchy-shell -q shell togglePanelAt right 9` |  |  | default/hypr/bindings/utilities.lua |
| OMA-9-285 | `SUPER + CTRL + L` | Lock system | `omarchy-system-lock` |  |  | default/hypr/bindings/utilities.lua |
| OMA-9-286 | `SUPER + CTRL + Z` | Zoom in | Lua function: increase `cursor.zoom_factor` by 1 |  |  | default/hypr/bindings/utilities.lua |
| OMA-9-287 | `SUPER + CTRL + ALT + Z` | Reset zoom | Lua function: set `cursor.zoom_factor` to 1 |  |  | default/hypr/bindings/utilities.lua |
| OMA-9-288 | `RETURN` | Capture highlighted window | `omarchy-capture-region --take-window` |  | Only while a `selection` layer (slurp) is open | default/hypr/bindings/utilities.lua |
| OMA-9-289 | `CTRL + RETURN` | Capture entire screen | `omarchy-capture-region --take-fullscreen` |  | Only while a `selection` layer (slurp) is open | default/hypr/bindings/utilities.lua |
| OMA-9-290 | `TAB` | Select next window to capture | `omarchy-capture-region --select-window next` |  | Only while a `selection` layer (slurp) is open | default/hypr/bindings/utilities.lua |
| OMA-9-291 | `CTRL + TAB` | Select previous window to capture | `omarchy-capture-region --select-window prev` |  | Only while a `selection` layer (slurp) is open | default/hypr/bindings/utilities.lua |
| OMA-9-292 | `LEFT` | Select window to capture | `omarchy-capture-region --select-window left` |  | Only while a `selection` layer (slurp) is open | default/hypr/bindings/utilities.lua |
| OMA-9-293 | `RIGHT` | Select window to capture | `omarchy-capture-region --select-window right` |  | Only while a `selection` layer (slurp) is open | default/hypr/bindings/utilities.lua |
| OMA-9-294 | `UP` | Select window to capture | `omarchy-capture-region --select-window up` |  | Only while a `selection` layer (slurp) is open | default/hypr/bindings/utilities.lua |
| OMA-9-295 | `DOWN` | Select window to capture | `omarchy-capture-region --select-window down` |  | Only while a `selection` layer (slurp) is open | default/hypr/bindings/utilities.lua |
| OMA-9-296 | `SUPER + CTRL + X` | Toggle dictation | `voxtype record toggle` |  | `voxtype` present | default/hypr/bindings/voxtype.lua |
| OMA-9-297 | `F9` | Start dictation (push-to-talk) | `voxtype record start` |  | `voxtype` present | default/hypr/bindings/voxtype.lua |
| OMA-9-298 | `F9` | Stop dictation (push-to-talk) | `voxtype record stop` | release | `voxtype` present | default/hypr/bindings/voxtype.lua |

## 10. Themes

### Bundled themes

| ID | Theme | Mode | Backgrounds | Optional files | Source |
|---|---|---|---|---|---|
| OMA-10-001 | `catppuccin` | dark | 4 | `neovim.lua`, `vscode.json` | themes/catppuccin |
| OMA-10-002 | `catppuccin-latte` | light | 2 | `neovim.lua`, `vscode.json` | themes/catppuccin-latte |
| OMA-10-003 | `ethereal` | dark | 3 | (none) | themes/ethereal |
| OMA-10-004 | `everforest` | dark | 2 | `neovim.lua`, `vscode.json` | themes/everforest |
| OMA-10-005 | `flexoki-light` | light | 2 | `chromium.theme`, `neovim.lua`, `vscode.json` | themes/flexoki-light |
| OMA-10-006 | `gruvbox` | dark | 6 | `neovim.lua`, `vscode.json` | themes/gruvbox |
| OMA-10-007 | `hackerman` | dark | 3 | `neovim.lua`, `vscode.json` | themes/hackerman |
| OMA-10-008 | `kanagawa` | dark | 2 | `hyprland.lua`, `neovim.lua`, `vscode.json` | themes/kanagawa |
| OMA-10-009 | `last-horizon` | dark | 4 | `btop.theme`, `chromium.theme`, `hyprland.lua`, `vscode.json` | themes/last-horizon |
| OMA-10-010 | `lumon` | dark | 3 | `btop.theme`, `chromium.theme`, `hyprland.lua`, `neovim.lua`, `vscode.json` | themes/lumon |
| OMA-10-011 | `lupine` | light | 6 | (none) | themes/lupine |
| OMA-10-012 | `matte-black` | dark | 4 | `neovim.lua`, `vscode.json` | themes/matte-black |
| OMA-10-013 | `miasma` | dark | 3 | (none) | themes/miasma |
| OMA-10-014 | `nord` | dark | 4 | `neovim.lua`, `vscode.json` | themes/nord |
| OMA-10-015 | `osaka-jade` | dark | 4 | `neovim.lua`, `vscode.json` | themes/osaka-jade |
| OMA-10-016 | `retro-82` | dark | 9 | `btop.theme`, `chromium.theme`, `hyprland.lua`, `neovim.lua`, `vscode.json` | themes/retro-82 |
| OMA-10-017 | `ristretto` | dark | 5 | (none) | themes/ristretto |
| OMA-10-018 | `rose-pine` | light | 4 | `chromium.theme`, `neovim.lua`, `vscode.json` | themes/rose-pine |
| OMA-10-019 | `solitude` | dark | 5 | `btop.theme`, `hyprland.lua`, `neovim.lua`, `vscode.json` | themes/solitude |
| OMA-10-020 | `tokyo-night` | dark | 8 | `keyboard.rgb`, `neovim.lua`, `shell.lock.toml`, `vscode.json` | themes/tokyo-night |
| OMA-10-021 | `vantablack` | dark | 5 | (none) | themes/vantablack |
| OMA-10-022 | `white` | light | 4 | (none) | themes/white |

| ID | Requirement | Source |
|---|---|---|
| OMA-10-023 | Each theme must contain `colors.toml`, `backgrounds/`, `icons.theme`, `preview.png`, `preview-unlock.png` and `unlock.png`. | themes/* |
| OMA-10-024 | The theme display names are not determined from the files. The command normalizes names to lower case with hyphens. | bin/omarchy-theme-set |
| OMA-10-025 | The default theme must be `Tokyo Night`. | install/user/theme.sh |

### Templates

| ID | Template | Source |
|---|---|---|
| OMA-10-026 | `alacritty.toml.tpl` | default/themed/alacritty.toml.tpl |
| OMA-10-027 | `btop.theme.tpl` | default/themed/btop.theme.tpl |
| OMA-10-028 | `chromium.theme.tpl` | default/themed/chromium.theme.tpl |
| OMA-10-029 | `claude.json.tpl` | default/themed/claude.json.tpl |
| OMA-10-030 | `foot.ini.tpl` | default/themed/foot.ini.tpl |
| OMA-10-031 | `ghostty.conf.tpl` | default/themed/ghostty.conf.tpl |
| OMA-10-032 | `gum_env.lua.tpl` | default/themed/gum_env.lua.tpl |
| OMA-10-033 | `helix.toml.tpl` | default/themed/helix.toml.tpl |
| OMA-10-034 | `hermes.yaml.tpl` | default/themed/hermes.yaml.tpl |
| OMA-10-035 | `hyprland-preview-share-picker.css.tpl` | default/themed/hyprland-preview-share-picker.css.tpl |
| OMA-10-036 | `hyprland.lua.tpl` | default/themed/hyprland.lua.tpl |
| OMA-10-037 | `keyboard.rgb.tpl` | default/themed/keyboard.rgb.tpl |
| OMA-10-038 | `kitty.conf.tpl` | default/themed/kitty.conf.tpl |
| OMA-10-039 | `neovim.lua.tpl` | default/themed/neovim.lua.tpl |
| OMA-10-040 | `obsidian.css.tpl` | default/themed/obsidian.css.tpl |
| OMA-10-041 | `pi.json.tpl` | default/themed/pi.json.tpl |
| OMA-10-042 | `shell.toml.tpl` | default/themed/shell.toml.tpl |
| OMA-10-043 | `t3code.json.tpl` | default/themed/t3code.json.tpl |
| OMA-10-044 | `vscode-theme.json.tpl` | default/themed/vscode-theme.json.tpl |

| ID | Requirement | Source |
|---|---|---|
| OMA-10-045 | User templates in `~/.config/omarchy/themed/` must take precedence over the default templates. | bin/omarchy-theme-set-templates |
| OMA-10-046 | A template must not overwrite a file that the theme supplies. | bin/omarchy-theme-set-templates |

### Theme change procedure (`omarchy-theme-set`)

| ID | Requirement | Source |
|---|---|---|
| OMA-10-047 | Normalize the theme name. | bin/omarchy-theme-set |
| OMA-10-048 | Take a lock on `$XDG_RUNTIME_DIR/omarchy-theme-set.lock` with `flock`. | bin/omarchy-theme-set |
| OMA-10-049 | Copy the official theme into `current/next-theme`, then copy the user theme over it. | bin/omarchy-theme-set |
| OMA-10-050 | For a git-cloned user theme, remove `*.lua`, the alacritty, foot, ghostty and kitty configs, `vscode.json` and symlinks. | bin/omarchy-theme-set |
| OMA-10-051 | If `colors.toml` is missing, generate it from `alacritty.toml`. | bin/omarchy-theme-set |
| OMA-10-052 | Render the templates. | bin/omarchy-theme-set |
| OMA-10-053 | Move the result to `current/theme` and write `current/theme.name`. | bin/omarchy-theme-set |
| OMA-10-054 | Set the background symlink. Send the transition to the shell through IPC. | bin/omarchy-theme-set |
| OMA-10-055 | Run the post-theme commands in parallel. | bin/omarchy-theme-set |
| OMA-10-056 | Run the `theme-set` hook. | bin/omarchy-theme-set |
| OMA-10-057 | Preload the theme switcher and the background cache. | bin/omarchy-theme-set |

### Applications that a theme change updates

| ID | Target | Command | Source |
|---|---|---|---|
| OMA-10-058 | Terminals (foot, Alacritty, kitty, Ghostty) | `omarchy-restart-terminal`; `omarchy-theme-set-foot` | bin/omarchy-theme-set |
| OMA-10-059 | Hyprland | `hyprctl reload` | bin/omarchy-theme-set |
| OMA-10-060 | btop | `omarchy-restart-btop` | bin/omarchy-theme-set |
| OMA-10-061 | opencode | `omarchy-restart-opencode` | bin/omarchy-theme-set |
| OMA-10-062 | Helix | `omarchy-restart-helix` | bin/omarchy-theme-set |
| OMA-10-063 | tmux | `omarchy-theme-set-tmux` | bin/omarchy-theme-set |
| OMA-10-064 | GNOME / GTK | `omarchy-theme-set-gnome` | bin/omarchy-theme-set |
| OMA-10-065 | pi | `omarchy-theme-set-pi` | bin/omarchy-theme-set |
| OMA-10-066 | Claude Code | `omarchy-theme-set-claude` | bin/omarchy-theme-set |
| OMA-10-067 | Hermes | `omarchy-theme-set-hermes` | bin/omarchy-theme-set |
| OMA-10-068 | T3 Code | `omarchy-theme-set-t3code` | bin/omarchy-theme-set |
| OMA-10-069 | Chromium | `omarchy-theme-set-browser` (managed policy through sudo) | bin/omarchy-theme-set; etc/sudoers.d/ |
| OMA-10-070 | VS Code | `omarchy-theme-set-vscode` | bin/omarchy-theme-set |
| OMA-10-071 | Obsidian | `omarchy-theme-set-obsidian` | bin/omarchy-theme-set |
| OMA-10-072 | Keyboard RGB | `omarchy-theme-set-keyboard` | bin/omarchy-theme-set |
| OMA-10-073 | Shell (bar, menu, lock) | Shell reads `colors.toml` and `shell.toml` | docs/theming.md |
| OMA-10-074 | Neovim | `neovim.lua` in the current theme | default/themed/neovim.lua |

### Backgrounds

| ID | Requirement | Source |
|---|---|---|
| OMA-10-075 | User backgrounds must be in `~/.config/omarchy/backgrounds/<theme>`. | bin/omarchy-theme-bg-* |
| OMA-10-076 | `omarchy-theme-bg-next` must select the next background. | bin/omarchy-theme-bg-next |
| OMA-10-077 | User themes must be in `~/.config/omarchy/themes/`. `omarchy-theme-install` must install a theme from a git URL. | bin/omarchy-theme-install |

## 11. Commands

| ID | Requirement | Source |
|---|---|---|
| OMA-11-001 | The `omarchy` router must list the command groups with the descriptions in `GROUP_DESCRIPTIONS`. | bin/omarchy |
| OMA-11-002 | Each command must declare `omarchy:summary`. It can declare `omarchy:hidden`, `omarchy:requires-sudo`, `omarchy:args`, `omarchy:group` and `omarchy:alias`. | agents/skills/command-metadata.md |

### Group `(root)`

Group description: not determined (no `GROUP_DESCRIPTIONS` entry).

| ID | Command | Function | Hidden | Sudo | Source |
|---|---|---|---|---|---|
| OMA-11-003 | `omarchy` | Router: list the command groups and run `omarchy-<group>-<name>`. | no | no | bin/omarchy |

### Group `agent`

Group description: AI coding agent usage data

| ID | Command | Function | Hidden | Sudo | Source |
|---|---|---|---|---|---|
| OMA-11-004 | `omarchy-agent` `[--inline] [--pick]` | Launch the default coding agent in a terminal | no | no | bin/omarchy-agent |
| OMA-11-005 | `omarchy-agent-crash` `<pid> [comm] [exe] [signal]` | Diagnose a crashed process with the default coding agent | no | no | bin/omarchy-agent-crash |
| OMA-11-006 | `omarchy-agent-prompt` `[--inline] <prompt...>` | Launch the default coding agent with a prompt | no | no | bin/omarchy-agent-prompt |
| OMA-11-007 | `omarchy-agent-usage-claude` `[--force] [--limits-only]` | Print the Claude Code usage record as JSON | yes | no | bin/omarchy-agent-usage-claude |
| OMA-11-008 | `omarchy-agent-usage-codex` `[--force] [--limits-only]` | Print the Codex usage record as JSON | yes | no | bin/omarchy-agent-usage-codex |
| OMA-11-009 | `omarchy-agent-usage-fireworks` `[--force] [--limits-only]` | Print the Fireworks usage record as JSON | yes | no | bin/omarchy-agent-usage-fireworks |
| OMA-11-010 | `omarchy-agent-usage-update` `[--force] [--limits-only] [--except <agent>] [agent...]` | Regenerate the AI agent usage data files | no | no | bin/omarchy-agent-usage-update |

### Group `apply`

Group description: not determined (no `GROUP_DESCRIPTIONS` entry).

| ID | Command | Function | Hidden | Sudo | Source |
|---|---|---|---|---|---|
| OMA-11-011 | `omarchy-apply-hardware` | Apply Omarchy hardware-specific packages and system configuration | yes | yes | bin/omarchy-apply-hardware |
| OMA-11-012 | `omarchy-apply-lock` | Configure Quickshell lock screen authentication | yes | yes | bin/omarchy-apply-lock |
| OMA-11-013 | `omarchy-apply-system` | Apply Omarchy system setup in the installed target | yes | yes | bin/omarchy-apply-system |

### Group `audio`

Group description: Audio input and output controls

| ID | Command | Function | Hidden | Sudo | Source |
|---|---|---|---|---|---|
| OMA-11-014 | `omarchy-audio-input-mute` | Toggle microphone mute. Drives the hardware mic-mute LED on laptops that expose one. | no | no | bin/omarchy-audio-input-mute |
| OMA-11-015 | `omarchy-audio-input-set-default` `<node-id> <source-name>` | Set the default audio input and move active streams | no | no | bin/omarchy-audio-input-set-default |
| OMA-11-016 | `omarchy-audio-output-set-default` `<node-id> <sink-name>` | Set the default audio output and move active streams | no | no | bin/omarchy-audio-output-set-default |
| OMA-11-017 | `omarchy-audio-output-sink` `[sink-name]` | Print the sink whose volume and mute a given output really uses | no | no | bin/omarchy-audio-output-sink |
| OMA-11-018 | `omarchy-audio-output-switch` | Switch between audio outputs while preserving the mute status | no | no | bin/omarchy-audio-output-switch |
| OMA-11-019 | `omarchy-audio-output-volume` `<raise\|lower\|mute-toggle\|+N\|-N>` | Adjust output volume and show the Omarchy OSD | no | no | bin/omarchy-audio-output-volume |
| OMA-11-020 | `omarchy-audio-sink-availability` | Print PulseAudio sink availability for the shell | no | no | bin/omarchy-audio-sink-availability |
| OMA-11-021 | `omarchy-audio-source-switch` `[next\|previous]` | Cycle to the next media source and transfer playback when the current source is playing | no | no | bin/omarchy-audio-source-switch |
| OMA-11-022 | `omarchy-audio-tuning` `<on\|off\|status\|match\|fronted-sink> [--force]` | Manage the speaker tuning for this laptop | no | no | bin/omarchy-audio-tuning |

### Group `bar`

Group description: Omarchy shell bar layout and settings

| ID | Command | Function | Hidden | Sudo | Source |
|---|---|---|---|---|---|
| OMA-11-023 | `omarchy-bar` `use <id> \| reset \| defaults \| position <top\|bottom\|left\|right> \| transparent <true\|false\|toggle> \| put <id> [placement] \| move <id> [placement] \| set <id> <key> <value> [--json] [placement]` | Configure the bar and its widget layout | no | no | bin/omarchy-bar |
| OMA-11-024 | `omarchy-bar-text-color` | Choose a legible transparent bar text color | yes | no | bin/omarchy-bar-text-color |

### Group `battery`

Group description: Battery status helpers

| ID | Command | Function | Hidden | Sudo | Source |
|---|---|---|---|---|---|
| OMA-11-025 | `omarchy-battery-low` `<percentage>` | Send the low battery warning notification and run battery-low hooks. | yes | no | bin/omarchy-battery-low |
| OMA-11-026 | `omarchy-battery-present` | Returns true if a battery is present on the system. | no | no | bin/omarchy-battery-present |
| OMA-11-027 | `omarchy-battery-status` `[--shell]` | Returns a formatted battery status string with percentage and power draw/charge. | no | no | bin/omarchy-battery-status |

### Group `bluetooth`

Group description: Bluetooth device controls

| ID | Command | Function | Hidden | Sudo | Source |
|---|---|---|---|---|---|
| OMA-11-028 | `omarchy-bluetooth-device` `[pair\|connect\|disconnect\|forget] <address>` | Control a Bluetooth device | no | no | bin/omarchy-bluetooth-device |
| OMA-11-029 | `omarchy-bluetooth-power` `<on\|off\|toggle\|is-on>` | Turn Bluetooth on or off, remembered across reboots | no | no | bin/omarchy-bluetooth-power |

### Group `branding`

Group description: About and screensaver branding

| ID | Command | Function | Hidden | Sudo | Source |
|---|---|---|---|---|---|
| OMA-11-030 | `omarchy-branding-about` `<image\|text\|reset>` | Edit, set, or reset About branding | no | no | bin/omarchy-branding-about |
| OMA-11-031 | `omarchy-branding-screensaver` `<image\|text\|reset>` | Edit, set, or reset screensaver branding | no | no | bin/omarchy-branding-screensaver |

### Group `brightness`

Group description: Display and keyboard brightness

| ID | Command | Function | Hidden | Sudo | Source |
|---|---|---|---|---|---|
| OMA-11-032 | `omarchy-brightness-display` `[--no-osd] [--monitor name] [+N%\|N%-\|N%\|off\|on]` | Show or adjust brightness on the focused display. | no | no | bin/omarchy-brightness-display |
| OMA-11-033 | `omarchy-brightness-display-apple` `[--no-osd] [+N%\|N%-\|N%]` | Show or adjust Apple Studio Display and Apple XDR Display brightness using asdcontrol. | no | no | bin/omarchy-brightness-display-apple |
| OMA-11-034 | `omarchy-brightness-display-ddc` `<monitor> [+N%\|N%-\|N%]` | Show or adjust DDC/CI display brightness for a Hyprland monitor. | no | no | bin/omarchy-brightness-display-ddc |
| OMA-11-035 | `omarchy-brightness-keyboard` `[--no-osd] <up\|down\|cycle\|off\|restore>` | Adjust keyboard backlight brightness using available steps. | no | no | bin/omarchy-brightness-keyboard |
| OMA-11-036 | `omarchy-brightness-keyboard-mute` `<on\|off>` | Set the mic-mute indicator LED on laptops that expose a platform::micmute LED node. | no | no | bin/omarchy-brightness-keyboard-mute |

### Group `capture`

Group description: Screenshots and screen recording

| ID | Command | Function | Hidden | Sudo | Source |
|---|---|---|---|---|---|
| OMA-11-037 | `omarchy-capture-qr` | Decode a QR code from a screenshot region | no | no | bin/omarchy-capture-qr |
| OMA-11-038 | `omarchy-capture-region` `[region\|windows\|smart\|fullscreen] [--keep-freeze] [--match-monitor] \| --take-fullscreen \| --take-window \| --select-window <next\|prev\|left\|right\|up\|down>` | Pick a screen region over frozen screen content | yes | no | bin/omarchy-capture-region |
| OMA-11-039 | `omarchy-capture-screenrecording` `[--fullscreen] [--with-desktop-audio] [--with-microphone-audio] [--with-webcam] [--webcam-device=<device>] [--webcam-size=<small\|medium\|large>] [--resolution=<size>] [--stop-recording]` | Start or stop screen recording | no | no | bin/omarchy-capture-screenrecording |
| OMA-11-040 | `omarchy-capture-screenrecording-with-webcam` | Pick a webcam and start a screen recording with it | no | no | bin/omarchy-capture-screenrecording-with-webcam |
| OMA-11-041 | `omarchy-capture-screenshot` `[smart\|region\|windows\|fullscreen] [slurp\|copy\|save] [--editor=<name>]` | Take a screenshot | no | no | bin/omarchy-capture-screenshot |
| OMA-11-042 | `omarchy-capture-text` | Extract text from a screenshot region with OCR | no | no | bin/omarchy-capture-text |
| OMA-11-043 | `omarchy-capture-webcam-list` | List webcam devices that support video capture | yes | no | bin/omarchy-capture-webcam-list |
| OMA-11-044 | `omarchy-capture-webcam-resize` `<smaller\|larger\|reset\|small\|medium\|large>` | Resize the active webcam recording overlay | no | no | bin/omarchy-capture-webcam-resize |

### Group `channel`

Group description: Omarchy release channel management

| ID | Command | Function | Hidden | Sudo | Source |
|---|---|---|---|---|---|
| OMA-11-045 | `omarchy-channel-current` | Print the active Omarchy package channel | no | no | bin/omarchy-channel-current |
| OMA-11-046 | `omarchy-channel-set` `<stable\|rc\|edge\|dev>` | Set the Omarchy package channel. | no | yes | bin/omarchy-channel-set |

### Group `chromium`

Group description: not determined (no `GROUP_DESCRIPTIONS` entry).

| ID | Command | Function | Hidden | Sudo | Source |
|---|---|---|---|---|---|
| OMA-11-047 | `omarchy-chromium-copy-url-host` | Native messaging host: copy a Chromium tab URL to the clipboard | yes | no | bin/omarchy-chromium-copy-url-host |
| OMA-11-048 | `omarchy-chromium-ytdlp-host` | Native messaging host: download the URL sent by the yt-dlp Chromium extension | yes | no | bin/omarchy-chromium-ytdlp-host |

### Group `clipboard`

Group description: Clipboard helpers

| ID | Command | Function | Hidden | Sudo | Source |
|---|---|---|---|---|---|
| OMA-11-049 | `omarchy-clipboard-open` `--history-index <index>` | Open a clipboard history entry | yes | no | bin/omarchy-clipboard-open |
| OMA-11-050 | `omarchy-clipboard-paste-file` `[--copy-only] <mime-type> <path>` | Copy a file to the clipboard and paste it | yes | no | bin/omarchy-clipboard-paste-file |
| OMA-11-051 | `omarchy-clipboard-paste-text` `[--shift-insert] [--copy-only] [--history-index <index>\|<text>]` | Copy text to the clipboard and type or paste it | yes | no | bin/omarchy-clipboard-paste-text |

### Group `cmd`

Group description: Command and shortcut helpers

| ID | Command | Function | Hidden | Sudo | Source |
|---|---|---|---|---|---|
| OMA-11-052 | `omarchy-cmd-browser-handoff` `<browser-command> [browser-args...]` | Hand a command line to the running Chromium-based browser | yes | no | bin/omarchy-cmd-browser-handoff |
| OMA-11-053 | `omarchy-cmd-default-browser` | Print the desktop entry ID of the default web browser | yes | no | bin/omarchy-cmd-default-browser |
| OMA-11-054 | `omarchy-cmd-missing` | Check whether any required commands are missing | no | no | bin/omarchy-cmd-missing |
| OMA-11-055 | `omarchy-cmd-present` | Check whether all required commands are available | no | no | bin/omarchy-cmd-present |
| OMA-11-056 | `omarchy-cmd-terminal-cwd` | Print the current working directory of the active terminal window | yes | no | bin/omarchy-cmd-terminal-cwd |

### Group `crash`

Group description: not determined (no `GROUP_DESCRIPTIONS` entry).

| ID | Command | Function | Hidden | Sudo | Source |
|---|---|---|---|---|---|
| OMA-11-057 | `omarchy-crash-watch` | Watch for process crashes and offer an AI diagnosis | yes | no | bin/omarchy-crash-watch |

### Group `debug`

Group description: Diagnostics and support logs

| ID | Command | Function | Hidden | Sudo | Source |
|---|---|---|---|---|---|
| OMA-11-058 | `omarchy-debug` `[--no-sudo] [--print]` | Print debugging information | no | yes | bin/omarchy-debug |
| OMA-11-059 | `omarchy-debug-idle` `[log-lines]` | Show idle, screensaver, and lock diagnostics | no | no | bin/omarchy-debug-idle |

### Group `default`

Group description: Default application selection

| ID | Command | Function | Hidden | Sudo | Source |
|---|---|---|---|---|---|
| OMA-11-060 | `omarchy-default-agent` `[pi\|omp\|opencode\|claude\|codex\|grok\|gemini\|openclaw\|hermes\|copilot\|crush\|cursor-agent\|muse]` | Set and launch the default coding agent | no | no | bin/omarchy-default-agent |
| OMA-11-061 | `omarchy-default-browser` `[chromium\|chrome\|brave\|brave-origin\|edge\|firefox\|zen]` | Set the default browser for Omarchy and XDG handlers | no | no | bin/omarchy-default-browser |
| OMA-11-062 | `omarchy-default-editor` `[code\|cursor\|zed\|sublime_text\|helix\|vim\|emacs\|nvim]` | Set the default editor used by omarchy-launch-editor | no | no | bin/omarchy-default-editor |
| OMA-11-063 | `omarchy-default-terminal` `[alacritty\|foot\|ghostty\|kitty]` | Set the default terminal used by xdg-terminal-exec | no | no | bin/omarchy-default-terminal |

### Group `dev`

Group description: Omarchy development tools

| ID | Command | Function | Hidden | Sudo | Source |
|---|---|---|---|---|---|
| OMA-11-064 | `omarchy-dev-add-migration` `[--no-edit]` | Create a new Omarchy migration in the current source tree. | no | no | bin/omarchy-dev-add-migration |
| OMA-11-065 | `omarchy-dev-benchmark-cli` `[--repeat=<count>]` | Measure Omarchy CLI response times | no | no | bin/omarchy-dev-benchmark-cli |
| OMA-11-066 | `omarchy-dev-benchmark-theme-switcher` `[--repeat=<count>] [--keep-cache]` | Measure theme switcher cache and selector prep times | no | no | bin/omarchy-dev-benchmark-theme-switcher |
| OMA-11-067 | `omarchy-dev-font` `[list\|add] <name> <svg-file-or-url> [--codepoint U+E9xx] [--font PATH]` | Add branded glyphs to the Omarchy icon font | no | no | bin/omarchy-dev-font |
| OMA-11-068 | `omarchy-dev-install-ydoo` | Install and enable ydotool mouse automation for Omarchy development | no | yes | bin/omarchy-dev-install-ydoo |
| OMA-11-069 | `omarchy-dev-link` `<path-to-checkout> [--no-reboot]` | Point Omarchy at a local checkout after reboot | no | no | bin/omarchy-dev-link |
| OMA-11-070 | `omarchy-dev-pkg-test` `[package-name] [path-to-checkout]` | Build and install an Omarchy package from a local checkout | no | no | bin/omarchy-dev-pkg-test |
| OMA-11-071 | `omarchy-dev-status` | Show the current Omarchy dev-link state | no | no | bin/omarchy-dev-status |
| OMA-11-072 | `omarchy-dev-theme-preview` `[theme-name\|theme-dir\|colors.toml] [--no-color] [--no-osc\|--osc]` | Preview an Omarchy theme palette in the terminal | no | no | bin/omarchy-dev-theme-preview |
| OMA-11-073 | `omarchy-dev-ui-preview` `[section]` | Open the omarchy-shell dev gallery (qs.Ui kit preview) | no | no | bin/omarchy-dev-ui-preview |
| OMA-11-074 | `omarchy-dev-unlink` `[--no-reboot]` | Restore Omarchy to the package install after reboot | no | no | bin/omarchy-dev-unlink |

### Group `disk`

Group description: Disk performance helpers

| ID | Command | Function | Hidden | Sudo | Source |
|---|---|---|---|---|---|
| OMA-11-075 | `omarchy-disk-speedtest` `[target-dir]` | Measure live disk read and write speed | no | no | bin/omarchy-disk-speedtest |

### Group `display`

Group description: Display and text scaling

| ID | Command | Function | Hidden | Sudo | Source |
|---|---|---|---|---|---|
| OMA-11-076 | `omarchy-display-text-size` `[size\|reset]` | Scale text everywhere — omarchy shell, GTK apps, and terminals | no | no | bin/omarchy-display-text-size |

### Group `dns`

Group description: DNS resolver configuration

| ID | Command | Function | Hidden | Sudo | Source |
|---|---|---|---|---|---|
| OMA-11-077 | `omarchy-dns` `[Cloudflare\|Google\|DHCP\|Custom]` | Show or configure the system DNS provider | no | no | bin/omarchy-dns |

### Group `done`

Group description: not determined (no `GROUP_DESCRIPTIONS` entry).

| ID | Command | Function | Hidden | Sudo | Source |
|---|---|---|---|---|---|
| OMA-11-078 | `omarchy-done` `<check\|mark\|ensure> <name>` | Check or mark completed Omarchy setup tasks | yes | no | bin/omarchy-done |

### Group `drive`

Group description: Drive selection and encryption

| ID | Command | Function | Hidden | Sudo | Source |
|---|---|---|---|---|---|
| OMA-11-079 | `omarchy-drive-info` `<drive>` | Print drive information such as size, model, and mount details | no | no | bin/omarchy-drive-info |
| OMA-11-080 | `omarchy-drive-password` | Set a new encryption password for a drive selected. | no | yes | bin/omarchy-drive-password |
| OMA-11-081 | `omarchy-drive-select` | Select a drive from a list with info that includes space and brand. Used by omarchy-drive-password. | no | no | bin/omarchy-drive-select |

### Group `file`

Group description: File selection helpers

| ID | Command | Function | Hidden | Sudo | Source |
|---|---|---|---|---|---|
| OMA-11-082 | `omarchy-file-select` `[--title <title>] [--multiple] [--directory] [--extensions "<ext ext...>"]` | Pick files with the desktop file chooser | no | no | bin/omarchy-file-select |

### Group `font`

Group description: Font management

| ID | Command | Function | Hidden | Sudo | Source |
|---|---|---|---|---|---|
| OMA-11-083 | `omarchy-font-current` | Show current monospace font | no | no | bin/omarchy-font-current |
| OMA-11-084 | `omarchy-font-list` | List available monospace fonts | no | no | bin/omarchy-font-list |
| OMA-11-085 | `omarchy-font-set` `<font-name>` | Set the system monospace font | no | no | bin/omarchy-font-set |

### Group `games`

Group description: Game launchers and helpers

| ID | Command | Function | Hidden | Sudo | Source |
|---|---|---|---|---|---|
| OMA-11-086 | `omarchy-games-retro-cores` | List installed RetroArch core names | no | no | bin/omarchy-games-retro-cores |
| OMA-11-087 | `omarchy-games-retro-install` `[core path-to-game]` | Create a desktop launcher for a RetroArch game | no | no | bin/omarchy-games-retro-install |

### Group `git`

Group description: not determined (no `GROUP_DESCRIPTIONS` entry).

| ID | Command | Function | Hidden | Sudo | Source |
|---|---|---|---|---|---|
| OMA-11-088 | `omarchy-git-url-check` `<git-url>` | Check that a git URL names a repository, not a transport helper | yes | no | bin/omarchy-git-url-check |

### Group `hibernation`

Group description: Hibernation setup and removal

| ID | Command | Function | Hidden | Sudo | Source |
|---|---|---|---|---|---|
| OMA-11-089 | `omarchy-hibernation-available` | Check if hibernation is supported | no | no | bin/omarchy-hibernation-available |
| OMA-11-090 | `omarchy-hibernation-remove` | Remove hibernation setup including swap and boot resume settings | no | yes | bin/omarchy-hibernation-remove |
| OMA-11-091 | `omarchy-hibernation-setup` `[--force] [--no-rebuild]` | Set up hibernation with swap and boot resume configuration | no | yes | bin/omarchy-hibernation-setup |

### Group `hook`

Group description: User hook runner

| ID | Command | Function | Hidden | Sudo | Source |
|---|---|---|---|---|---|
| OMA-11-092 | `omarchy-hook` `[name] [args...]` | Run a named hook from ~/.config/omarchy/hooks/<name> and ~/.config/omarchy/hooks/<name>.d/. | no | no | bin/omarchy-hook |
| OMA-11-093 | `omarchy-hook-install` `<type> <file>` | Install a hook into ~/.config/omarchy/hooks/<type>.d/ | no | no | bin/omarchy-hook-install |

### Group `hw`

Group description: Hardware detection and controls

| ID | Command | Function | Hidden | Sudo | Source |
|---|---|---|---|---|---|
| OMA-11-094 | `omarchy-hw-asus-expertbook-b9406` | Detect ASUS ExpertBook B9406 series laptops on Intel Panther Lake. | no | no | bin/omarchy-hw-asus-expertbook-b9406 |
| OMA-11-095 | `omarchy-hw-asus-rog` | Detect whether the computer is an Asus ROG machine. | no | no | bin/omarchy-hw-asus-rog |
| OMA-11-096 | `omarchy-hw-asus-zenbook-ux5406aa` | Detect ASUS Zenbook UX5406AA series laptops on Intel Panther Lake. | no | no | bin/omarchy-hw-asus-zenbook-ux5406aa |
| OMA-11-097 | `omarchy-hw-clamshell` | Returns true when clamshell mode is active | yes | no | bin/omarchy-hw-clamshell |
| OMA-11-098 | `omarchy-hw-dell-xps-haptic-touchpad` | Match Dell XPS systems with the Synaptics haptic touchpad. | no | no | bin/omarchy-hw-dell-xps-haptic-touchpad |
| OMA-11-099 | `omarchy-hw-dell-xps-oled` | Match Dell XPS systems with LG OLED panel on Intel Panther Lake (Xe3) GPU. | no | no | bin/omarchy-hw-dell-xps-oled |
| OMA-11-100 | `omarchy-hw-dell-xps13-dx13260-ptl` | Match the Dell XPS 13 DX13260 with an Intel Panther Lake GPU. | no | no | bin/omarchy-hw-dell-xps13-dx13260-ptl |
| OMA-11-101 | `omarchy-hw-display` | Print the most likely display backlight device. | no | no | bin/omarchy-hw-display |
| OMA-11-102 | `omarchy-hw-external-monitors` | Returns true when an external monitor is physically connected. | no | no | bin/omarchy-hw-external-monitors |
| OMA-11-103 | `omarchy-hw-fingerprint` | Returns true when a fingerprint reader is present | yes | no | bin/omarchy-hw-fingerprint |
| OMA-11-104 | `omarchy-hw-framework16` | Detect whether the computer is a Framework Laptop 16. | no | no | bin/omarchy-hw-framework16 |
| OMA-11-105 | `omarchy-hw-hybrid-gpu` | Detect whether the system has an active hybrid GPU configuration | no | no | bin/omarchy-hw-hybrid-gpu |
| OMA-11-106 | `omarchy-hw-intel` | Detect whether the computer has an Intel CPU. | no | no | bin/omarchy-hw-intel |
| OMA-11-107 | `omarchy-hw-intel-ptl` | Detect whether the computer has an Intel Panther Lake GPU. | no | no | bin/omarchy-hw-intel-ptl |
| OMA-11-108 | `omarchy-hw-intel-sof` | Detect an Intel SOF-capable audio DSP | no | no | bin/omarchy-hw-intel-sof |
| OMA-11-109 | `omarchy-hw-laptop` | Returns true when running on a laptop (has a lid or laptop chassis). | no | no | bin/omarchy-hw-laptop |
| OMA-11-110 | `omarchy-hw-laptop-closed` | Returns true when the laptop lid is closed | yes | no | bin/omarchy-hw-laptop-closed |
| OMA-11-111 | `omarchy-hw-match` `<pattern>` | Match against the computer's DMI product name or product family (case-insensitive). | no | no | bin/omarchy-hw-match |
| OMA-11-112 | `omarchy-hw-nvidia` | Detect whether the computer has an NVIDIA GPU. | no | no | bin/omarchy-hw-nvidia |
| OMA-11-113 | `omarchy-hw-nvidia-display` | Detect whether NVIDIA drives the display (rather than a hybrid iGPU). | no | no | bin/omarchy-hw-nvidia-display |
| OMA-11-114 | `omarchy-hw-nvidia-gsp` | Detect whether the computer has an NVIDIA GPU with GSP firmware (Turing or newer). | no | no | bin/omarchy-hw-nvidia-gsp |
| OMA-11-115 | `omarchy-hw-nvidia-without-gsp` | Detect whether the computer has an NVIDIA GPU without GSP firmware (Maxwell/Pascal/Volta). | no | no | bin/omarchy-hw-nvidia-without-gsp |
| OMA-11-116 | `omarchy-hw-recover-internal-monitor` | Clear the internal-monitor-disable toggle if no external display is connected. | no | no | bin/omarchy-hw-recover-internal-monitor |
| OMA-11-117 | `omarchy-hw-surface` | Detect whether the computer is a Microsoft Surface device. | no | no | bin/omarchy-hw-surface |
| OMA-11-118 | `omarchy-hw-touchpad` | Print the detected Hyprland touchpad or trackpad device name | no | no | bin/omarchy-hw-touchpad |
| OMA-11-119 | `omarchy-hw-touchscreen` | Print the detected Hyprland touchscreen or tablet device name | no | no | bin/omarchy-hw-touchscreen |
| OMA-11-120 | `omarchy-hw-vulkan` | Detect whether Vulkan is available. | no | no | bin/omarchy-hw-vulkan |
| OMA-11-121 | `omarchy-hw-webcam` | Check whether a webcam is available | no | no | bin/omarchy-hw-webcam |

### Group `hyprland`

Group description: Hyprland window, monitor, and toggle controls

| ID | Command | Function | Hidden | Sudo | Source |
|---|---|---|---|---|---|
| OMA-11-122 | `omarchy-hyprland-focus-app` `<app-name>` | Focus a Hyprland window by application identity | no | no | bin/omarchy-hyprland-focus-app |
| OMA-11-123 | `omarchy-hyprland-monitor-clamshell` | Apply clamshell display state to Hyprland monitors | yes | no | bin/omarchy-hyprland-monitor-clamshell |
| OMA-11-124 | `omarchy-hyprland-monitor-external-active` | Returns true when Hyprland has an active external monitor | yes | no | bin/omarchy-hyprland-monitor-external-active |
| OMA-11-125 | `omarchy-hyprland-monitor-focused` | Print the name of the currently focused Hyprland monitor. | no | no | bin/omarchy-hyprland-monitor-focused |
| OMA-11-126 | `omarchy-hyprland-monitor-focused-apple` `[monitor]` | Return success if the focused or named Hyprland monitor is an Apple display. | no | no | bin/omarchy-hyprland-monitor-focused-apple |
| OMA-11-127 | `omarchy-hyprland-monitor-internal` `<on\|off\|toggle\|recover>` | Enable, disable, toggle, or recover the internal laptop display | no | no | bin/omarchy-hyprland-monitor-internal |
| OMA-11-128 | `omarchy-hyprland-monitor-internal-mirror` `<on\|off\|toggle\|recover>` | Enable, disable, toggle, or recover mirroring the internal display to an external monitor | no | no | bin/omarchy-hyprland-monitor-internal-mirror |
| OMA-11-129 | `omarchy-hyprland-monitor-laptop` | Print the name of the built-in laptop display, including disabled outputs. | no | no | bin/omarchy-hyprland-monitor-laptop |
| OMA-11-130 | `omarchy-hyprland-monitor-modeless` | Returns true when Hyprland has an enabled monitor with no mode | yes | no | bin/omarchy-hyprland-monitor-modeless |
| OMA-11-131 | `omarchy-hyprland-monitor-scaling` `[up\|down\|SCALE]` | Show, set, or adjust focused Hyprland monitor scaling | no | no | bin/omarchy-hyprland-monitor-scaling |
| OMA-11-132 | `omarchy-hyprland-monitor-watch` | Watch Hyprland monitor events and recover monitor toggles when a monitor is removed | no | no | bin/omarchy-hyprland-monitor-watch |
| OMA-11-133 | `omarchy-hyprland-reload-guard` | Pause or resume Hyprland config auto-reload around package transactions. | yes | no | bin/omarchy-hyprland-reload-guard |
| OMA-11-134 | `omarchy-hyprland-session-lock-stranded` `<own-pid>` | Returns true when the compositor holds a session lock no other locker is alive to own | yes | no | bin/omarchy-hyprland-session-lock-stranded |
| OMA-11-135 | `omarchy-hyprland-session-locked` | Returns true when the compositor holds a session lock | yes | no | bin/omarchy-hyprland-session-locked |
| OMA-11-136 | `omarchy-hyprland-toggle` `<flag-name> [on\|off\|toggle]` | Toggle permanent Hyprland flags by copying them into a directory that's sourced entirely. | no | no | bin/omarchy-hyprland-toggle |
| OMA-11-137 | `omarchy-hyprland-toggle-disabled` `<flag-name>` | Check if a Hyprland toggle is currently disabled (missing). | no | no | bin/omarchy-hyprland-toggle-disabled |
| OMA-11-138 | `omarchy-hyprland-toggle-enabled` `<flag-name>` | Check if a Hyprland toggle is currently enabled. | no | no | bin/omarchy-hyprland-toggle-enabled |
| OMA-11-139 | `omarchy-hyprland-window-close-all` | Close all open windows | no | no | bin/omarchy-hyprland-window-close-all |
| OMA-11-140 | `omarchy-hyprland-window-gaps-toggle` | Toggles the window gaps globally between no gaps and the default. | no | no | bin/omarchy-hyprland-window-gaps-toggle |
| OMA-11-141 | `omarchy-hyprland-window-pop` `[width height x y]` | Toggle to pop-out a tile to stay fixed on a display basis. | no | no | bin/omarchy-hyprland-window-pop |
| OMA-11-142 | `omarchy-hyprland-window-single-square-aspect-toggle` | Toggle single-window square aspect ratio. | no | no | bin/omarchy-hyprland-window-single-square-aspect-toggle |
| OMA-11-143 | `omarchy-hyprland-window-tiled-fullscreen-toggle` | Toggle tiled fullscreen for the focused Hyprland window | no | no | bin/omarchy-hyprland-window-tiled-fullscreen-toggle |
| OMA-11-144 | `omarchy-hyprland-window-transparency-toggle` | Toggles transparency for the currently focused window. | no | no | bin/omarchy-hyprland-window-transparency-toggle |
| OMA-11-145 | `omarchy-hyprland-window-width` `<save\|restore>` | Save or restore the focused Hyprland window width | no | no | bin/omarchy-hyprland-window-width |
| OMA-11-146 | `omarchy-hyprland-workspace-layout-toggle` | Toggle the layout on the current active workspace between dwindle and scrolling | no | no | bin/omarchy-hyprland-workspace-layout-toggle |

### Group `install`

Group description: Optional software installers

| ID | Command | Function | Hidden | Sudo | Source |
|---|---|---|---|---|---|
| OMA-11-147 | `omarchy-install-ai-chatgpt` | Install the ChatGPT desktop app | no | yes | bin/omarchy-install-ai-chatgpt |
| OMA-11-148 | `omarchy-install-ai-hermes` | Install the Hermes desktop app | no | yes | bin/omarchy-install-ai-hermes |
| OMA-11-149 | `omarchy-install-ai-openclaw` | Install the OpenClaw agent platform and its Control UI web app | no | yes | bin/omarchy-install-ai-openclaw |
| OMA-11-150 | `omarchy-install-ai-t3-code` | Install T3 Code and point it at the Omarchy palette | no | yes | bin/omarchy-install-ai-t3-code |
| OMA-11-151 | `omarchy-install-and-launch` `<display-name> <packages> <desktop-id>` | Install a packaged app and launch it once it finishes | no | no | bin/omarchy-install-and-launch |
| OMA-11-152 | `omarchy-install-app` `<display-name> <packages>` | Install a packaged app, surfacing the install in a floating terminal | no | no | bin/omarchy-install-app |
| OMA-11-153 | `omarchy-install-browser` `<chrome\|brave\|brave-origin\|edge\|firefox\|zen>` | Install a supported browser | no | no | bin/omarchy-install-browser |
| OMA-11-154 | `omarchy-install-chromium-copy-url` | Install the native messaging host for the Copy URL Chromium extension | no | no | bin/omarchy-install-chromium-copy-url |
| OMA-11-155 | `omarchy-install-chromium-google-account` | Allow Chromium to sign in to Google accounts by adding the required OAuth credentials | no | no | bin/omarchy-install-chromium-google-account |
| OMA-11-156 | `omarchy-install-chromium-ytdlp` | Install the native messaging host for the yt-dlp Chromium extension | no | no | bin/omarchy-install-chromium-ytdlp |
| OMA-11-157 | `omarchy-install-dev-env` `<ruby\|node\|bun\|deno\|go\|laravel\|symfony\|php\|python\|elixir\|phoenix\|rust\|java\|zig\|ocaml\|dotnet\|clojure\|scala>` | Install a supported development environment | no | yes | bin/omarchy-install-dev-env |
| OMA-11-158 | `omarchy-install-docker-dbs` | Install one of the supported databases in a Docker container with the suitable development options. | no | yes | bin/omarchy-install-docker-dbs |
| OMA-11-159 | `omarchy-install-editor-emacs` | Install Emacs with Omarchy theme and font integration via the omarchy-emacs AUR package | no | no | bin/omarchy-install-editor-emacs |
| OMA-11-160 | `omarchy-install-editor-helix` | Install Helix and configure it to use the current Omarchy theme | no | no | bin/omarchy-install-editor-helix |
| OMA-11-161 | `omarchy-install-editor-vscode` | Install VS Code and configure Omarchy defaults for secrets, updates, and theme | no | no | bin/omarchy-install-editor-vscode |
| OMA-11-162 | `omarchy-install-editor-zed` | Install Zed Editor and configure it with the current Omarchy theme | no | no | bin/omarchy-install-editor-zed |
| OMA-11-163 | `omarchy-install-font` `<display-name> <package> <family>` | Install a Nerd Font package and switch the system to it | no | no | bin/omarchy-install-font |
| OMA-11-164 | `omarchy-install-gaming-battlenet` | Install Battle.net standalone via umu-launcher + GE-Proton (no Steam, no Lutris, no Heroic). | no | yes | bin/omarchy-install-gaming-battlenet |
| OMA-11-165 | `omarchy-install-gaming-geforce-now` | Install and launch Geforce Now. | no | no | bin/omarchy-install-gaming-geforce-now |
| OMA-11-166 | `omarchy-install-gaming-gpu-lib32` | Install lib32 graphics drivers (Vulkan + NVIDIA) for any detected GPUs. | no | yes | bin/omarchy-install-gaming-gpu-lib32 |
| OMA-11-167 | `omarchy-install-gaming-heroic` | Install Heroic Games Launcher (Epic, GOG, Amazon Prime Gaming) with graphics drivers. | no | yes | bin/omarchy-install-gaming-heroic |
| OMA-11-168 | `omarchy-install-gaming-lutris` | Install Lutris with Wine + DXVK for running Windows games (Battle.net, EA, Ubisoft Connect, etc.) | no | yes | bin/omarchy-install-gaming-lutris |
| OMA-11-169 | `omarchy-install-gaming-retroarch` | Install RetroArch with the full libretro core set plus FBNeo and a ~/Games ROM directory. | no | no | bin/omarchy-install-gaming-retroarch |
| OMA-11-170 | `omarchy-install-gaming-steam` | Install Steam and graphics drivers selected for this system | no | yes | bin/omarchy-install-gaming-steam |
| OMA-11-171 | `omarchy-install-gaming-xbox-cloud` | Install Xbox Cloud Gaming as a web app and launch it. | no | no | bin/omarchy-install-gaming-xbox-cloud |
| OMA-11-172 | `omarchy-install-gaming-xbox-controllers` | Install support for using Xbox controllers with Steam/RetroArch/etc. | no | yes | bin/omarchy-install-gaming-xbox-controllers |
| OMA-11-173 | `omarchy-install-hermes-cli` `<--check\|--now\|--retire-mise>` | Install Hermes Desktop for the default agent; its runtime provides the hermes command | no | yes | bin/omarchy-install-hermes-cli |
| OMA-11-174 | `omarchy-install-openclaw-cli` `<--check\|--now>` | Install OpenClaw for the default agent as the self-updating copy under ~/.openclaw | no | yes | bin/omarchy-install-openclaw-cli |
| OMA-11-175 | `omarchy-install-preinstalls` | Restore the preinstalled Omarchy applications (web apps, TUIs, and selected packages). | no | yes | bin/omarchy-install-preinstalls |
| OMA-11-176 | `omarchy-install-service-1password` | Install 1Password and its Chromium extension. | no | yes | bin/omarchy-install-service-1password |
| OMA-11-177 | `omarchy-install-service-dropbox` | Install and start the Dropbox service. Must then be authenticated via the web. | no | no | bin/omarchy-install-service-dropbox |
| OMA-11-178 | `omarchy-install-service-nordvpn` | Install the NordVPN service with optional GUI. | no | yes | bin/omarchy-install-service-nordvpn |
| OMA-11-179 | `omarchy-install-service-once` | Install the ONCE service, enable its background service, and launch the TUI. | no | yes | bin/omarchy-install-service-once |
| OMA-11-180 | `omarchy-install-service-signal` | Install Signal and launch it. | no | yes | bin/omarchy-install-service-signal |
| OMA-11-181 | `omarchy-install-service-spotify` | Install Spotify. | no | yes | bin/omarchy-install-service-spotify |
| OMA-11-182 | `omarchy-install-service-sunshine` | Install Sunshine and open Moonlight streaming ports for LAN and Tailscale. | no | yes | bin/omarchy-install-service-sunshine |
| OMA-11-183 | `omarchy-install-service-tailscale` | Install the Tailscale mesh VPN service and a web app for the Tailscale Admin Console. | no | yes | bin/omarchy-install-service-tailscale |
| OMA-11-184 | `omarchy-install-terminal` `<alacritty\|foot\|ghostty\|kitty>` | Install one of the approved terminals and set it as the default for Omarchy (Super + Return etc). | no | yes | bin/omarchy-install-terminal |

### Group `installed`

Group description: Installed optional service checks

| ID | Command | Function | Hidden | Sudo | Source |
|---|---|---|---|---|---|
| OMA-11-185 | `omarchy-installed-service-dropbox` | Check whether Dropbox is installed and running | yes | no | bin/omarchy-installed-service-dropbox |
| OMA-11-186 | `omarchy-installed-service-tailscale` | Check whether Tailscale is installed and running | yes | no | bin/omarchy-installed-service-tailscale |

### Group `launch`

Group description: Application launchers

| ID | Command | Function | Hidden | Sudo | Source |
|---|---|---|---|---|---|
| OMA-11-187 | `omarchy-launch-1password` | Launch 1Password or start its installer when missing. | no | no | bin/omarchy-launch-1password |
| OMA-11-188 | `omarchy-launch-about` | Launch the fastfetch TUI that gives information about the current system. | no | no | bin/omarchy-launch-about |
| OMA-11-189 | `omarchy-launch-battlenet` `[--with-mangohud]` | Launch the installed Battle.net client via umu-launcher + GE-Proton. | no | no | bin/omarchy-launch-battlenet |
| OMA-11-190 | `omarchy-launch-browser` `[url]` | Launch the default browser as determined by xdg-settings. | no | no | bin/omarchy-launch-browser |
| OMA-11-191 | `omarchy-launch-config-editor` `<path>` | Open a config file in the user's editor and surface a toast | no | no | bin/omarchy-launch-config-editor |
| OMA-11-192 | `omarchy-launch-discord-community` | Open the Omarchy Discord community in the Discord app or a browser. | no | no | bin/omarchy-launch-discord-community |
| OMA-11-193 | `omarchy-launch-docker-tui` | Open the Docker TUI (lazydocker) with access to the Docker daemon | yes | no | bin/omarchy-launch-docker-tui |
| OMA-11-194 | `omarchy-launch-editor` `[--inline] <path>` | Launch the default editor selected via Omarchy defaults. | no | no | bin/omarchy-launch-editor |
| OMA-11-195 | `omarchy-launch-floating-terminal-with-presentation` `<command>` | Launch a floating terminal with the Omarchy presentation wrapper | no | no | bin/omarchy-launch-floating-terminal-with-presentation |
| OMA-11-196 | `omarchy-launch-nautilus` | Launch Files | no | no | bin/omarchy-launch-nautilus |
| OMA-11-197 | `omarchy-launch-nautilus-cwd` | Launch Files in the active terminal's current directory | no | no | bin/omarchy-launch-nautilus-cwd |
| OMA-11-198 | `omarchy-launch-openclaw` `[--tui [--message <text>]]` | Open the OpenClaw Control UI (or its terminal UI with --tui), onboarding or starting the gateway first when needed. | no | no | bin/omarchy-launch-openclaw |
| OMA-11-199 | `omarchy-launch-or-focus` `<window-pattern> <launch-command>` | Launch an app or focus an existing window matching a pattern | no | no | bin/omarchy-launch-or-focus |
| OMA-11-200 | `omarchy-launch-or-focus-tui` `[--app-id=<app-id>] <command> [args...]` | Launch a TUI or focus an existing terminal window for it | no | no | bin/omarchy-launch-or-focus-tui |
| OMA-11-201 | `omarchy-launch-or-focus-webapp` `<window-pattern> <url-and-flags...>` | Launch or focus on a given web app identified by the window-pattern. | no | no | bin/omarchy-launch-or-focus-webapp |
| OMA-11-202 | `omarchy-launch-screensaver` | Launch the Omarchy screensaver in the default terminal on the system with the correct font configuration. | no | no | bin/omarchy-launch-screensaver |
| OMA-11-203 | `omarchy-launch-shell` | Launch the Omarchy shell with its log kept in the journal | yes | no | bin/omarchy-launch-shell |
| OMA-11-204 | `omarchy-launch-signal` | Launch Signal or start its installer when missing. | no | no | bin/omarchy-launch-signal |
| OMA-11-205 | `omarchy-launch-spotify` | Launch Spotify or start its installer when missing. | no | no | bin/omarchy-launch-spotify |
| OMA-11-206 | `omarchy-launch-terminal` `[command...]` | Launch a terminal in the active terminal's current directory | no | no | bin/omarchy-launch-terminal |
| OMA-11-207 | `omarchy-launch-terminal-herdr` | Launch or attach to the persistent herdr session in a terminal | no | no | bin/omarchy-launch-terminal-herdr |
| OMA-11-208 | `omarchy-launch-terminal-tmux` | Launch or attach to the Work tmux session in a terminal | no | no | bin/omarchy-launch-terminal-tmux |
| OMA-11-209 | `omarchy-launch-tui` `[--app-id=<app-id>] <command> [args...]` | Launch a TUI command in the default terminal with Omarchy styling | no | no | bin/omarchy-launch-tui |
| OMA-11-210 | `omarchy-launch-webapp` `<url>` | Launch a URL as a web app in the default supported browser | no | no | bin/omarchy-launch-webapp |

### Group `menu`

Group description: Omarchy menu commands

| ID | Command | Function | Hidden | Sudo | Source |
|---|---|---|---|---|---|
| OMA-11-211 | `omarchy-menu` `[toggle\|summon\|close\|refresh\|ping] [route]` | Control the Omarchy menu (toggle / summon / close / refresh) | no | no | bin/omarchy-menu |
| OMA-11-212 | `omarchy-menu-clipboard` | Launch the clipboard manager | no | no | bin/omarchy-menu-clipboard |
| OMA-11-213 | `omarchy-menu-emoji` | Launch emojis | no | no | bin/omarchy-menu-emoji |
| OMA-11-214 | `omarchy-menu-emoji-insert` `<emoji>` | Insert an emoji into the focused application | yes | no | bin/omarchy-menu-emoji-insert |
| OMA-11-215 | `omarchy-menu-file` `label paths formats [menu args...]` | Pick a file from a menu | no | no | bin/omarchy-menu-file |
| OMA-11-216 | `omarchy-menu-herdr-keybindings` `[--print\|-p] [--config <path>]` | Display annotated Herdr keybindings using an interactive search menu. | no | no | bin/omarchy-menu-herdr-keybindings |
| OMA-11-217 | `omarchy-menu-images` `[--selected <image>] [--print-name] [--show-labels] [--filterable] [--lazy-thumbnails] [--preload] [--cache-only] <image-dir>...` | Open a generic image selector menu | no | no | bin/omarchy-menu-images |
| OMA-11-218 | `omarchy-menu-input` `prompt [menu args...]` | Prompt for text input from a menu | no | no | bin/omarchy-menu-input |
| OMA-11-219 | `omarchy-menu-keybindings` | Display Hyprland keybindings defined in your configuration using an interactive search menu. | no | no | bin/omarchy-menu-keybindings |
| OMA-11-220 | `omarchy-menu-plugin` `<enable\|disable\|clone\|remove>` | Pick a shell plugin to enable, disable, clone, or remove | no | no | bin/omarchy-menu-plugin |
| OMA-11-221 | `omarchy-menu-select` `prompt [option...] [-- menu args...]` | Pick one option from a menu | no | no | bin/omarchy-menu-select |
| OMA-11-222 | `omarchy-menu-timezone` | Select and set the system timezone | no | no | bin/omarchy-menu-timezone |
| OMA-11-223 | `omarchy-menu-tmux-keybindings` `[--print\|-p] [--config <path>]` | Display annotated Tmux keybindings using an interactive search menu. | no | no | bin/omarchy-menu-tmux-keybindings |

### Group `migrate`

Group description: Migration runner

| ID | Command | Function | Hidden | Sudo | Source |
|---|---|---|---|---|---|
| OMA-11-224 | `omarchy-migrate` `[--pending]` | Run pending Omarchy migrations. | no | no | bin/omarchy-migrate |
| OMA-11-225 | `omarchy-migrate-notify` | Notify the user when Omarchy has pending migrations | no | no | bin/omarchy-migrate-notify |

### Group `mise`

Group description: Mise tool wrappers

| ID | Command | Function | Hidden | Sudo | Source |
|---|---|---|---|---|---|
| OMA-11-226 | `omarchy-mise-install` `<package> [command-name [bin-name]]` | Install a small mise-backed wrapper for a given tool. | no | no | bin/omarchy-mise-install |

### Group `monitor`

Group description: Monitor status helpers

| ID | Command | Function | Hidden | Sudo | Source |
|---|---|---|---|---|---|
| OMA-11-227 | `omarchy-monitor-state` | Print monitor panel state for the shell | no | no | bin/omarchy-monitor-state |

### Group `network`

Group description: Network status helpers

| ID | Command | Function | Hidden | Sudo | Source |
|---|---|---|---|---|---|
| OMA-11-228 | `omarchy-network-band` `[auto\|2.4\|5\|6]` | Show or pin the Wi-Fi band for the active connection | no | no | bin/omarchy-network-band |
| OMA-11-229 | `omarchy-network-password` `<interface>` | Print the active Wi-Fi connection's password | no | no | bin/omarchy-network-password |
| OMA-11-230 | `omarchy-network-qr` `[--meta] [interface]` | Generate a Wi-Fi QR matrix for the shell | no | no | bin/omarchy-network-qr |
| OMA-11-231 | `omarchy-network-speedtest` `[down\|up]` | Measure live internet speed for one direction | no | no | bin/omarchy-network-speedtest |
| OMA-11-232 | `omarchy-network-status` `[--verbose]` | Print active network status for the shell | no | no | bin/omarchy-network-status |

### Group `notification`

Group description: Notification helpers

| ID | Command | Function | Hidden | Sudo | Source |
|---|---|---|---|---|---|
| OMA-11-233 | `omarchy-notification-battery` | Show the current battery status notification | no | no | bin/omarchy-notification-battery |
| OMA-11-234 | `omarchy-notification-dismiss` `<summary>` | Dismiss a notification by summary substring. Used by the first-run notifications to dismiss them after clicking for action. | no | no | bin/omarchy-notification-dismiss |
| OMA-11-235 | `omarchy-notification-send` `[--app-name <app-name>] [-g <glyph>] [-u <low\|normal\|critical>] [-i <icon>] [-t <ms>] [-r <id>] [-p] [--image <path-or-uri>] <headline> [description] [--exec <program> [args...]]` | Send an Omarchy desktop notification | no | no | bin/omarchy-notification-send |
| OMA-11-236 | `omarchy-notification-time` | Show the current time and date notification | no | no | bin/omarchy-notification-time |
| OMA-11-237 | `omarchy-notification-wait` `[timeout-seconds]` | Wait for the desktop notification server to accept notifications | yes | no | bin/omarchy-notification-wait |
| OMA-11-238 | `omarchy-notification-weather` | Toggle the current weather panel | no | no | bin/omarchy-notification-weather |

### Group `openclaw`

Group description: OpenClaw agent platform setup

| ID | Command | Function | Hidden | Sudo | Source |
|---|---|---|---|---|---|
| OMA-11-239 | `omarchy-openclaw-onboard` | Run OpenClaw's setup wizard the way Omarchy needs it: in the terminal, installing the gateway as a user service, and returning when it is done. | no | no | bin/omarchy-openclaw-onboard |

### Group `osd`

Group description: On-screen display status helpers

| ID | Command | Function | Hidden | Sudo | Source |
|---|---|---|---|---|---|
| OMA-11-240 | `omarchy-osd` `[-i\|--icon <icon>] [-m\|--message <text>] [-p\|--progress <0-100>] [-d\|--duration <ms>]` | Show the Omarchy Quickshell on-screen display | no | no | bin/omarchy-osd |

### Group `pkg`

Group description: Package management helpers

| ID | Command | Function | Hidden | Sudo | Source |
|---|---|---|---|---|---|
| OMA-11-241 | `omarchy-pkg-add` `<packages...>` | Install Arch packages if they are missing | no | yes | bin/omarchy-pkg-add |
| OMA-11-242 | `omarchy-pkg-aur-accessible` | Returns true if the AUR is up and available. | no | no | bin/omarchy-pkg-aur-accessible |
| OMA-11-243 | `omarchy-pkg-aur-add` `<packages...>` | Add the named packages to the system from the AUR if they're missing. Returns false if it couldn't be done. | no | no | bin/omarchy-pkg-aur-add |
| OMA-11-244 | `omarchy-pkg-aur-install` | Show a fuzzy-finder TUI for picking new AUR packages to install. | no | yes | bin/omarchy-pkg-aur-install |
| OMA-11-245 | `omarchy-pkg-drop` `<packages...>` | Remove all the named packages from the system if they're installed (otherwise ignore). | no | yes | bin/omarchy-pkg-drop |
| OMA-11-246 | `omarchy-pkg-install` | Show a fuzzy-finder TUI for picking new Arch and OPR packages to install. | no | yes | bin/omarchy-pkg-install |
| OMA-11-247 | `omarchy-pkg-missing` `<packages...>` | Returns true if any of the named packages are missing from the system (or false if they're all there). | no | no | bin/omarchy-pkg-missing |
| OMA-11-248 | `omarchy-pkg-present` `<packages...>` | Returns true if all of the named packages are installed on the system (or false if any of them are missing). | no | no | bin/omarchy-pkg-present |
| OMA-11-249 | `omarchy-pkg-remove` | Show a fuzzy-finder TUI for picking packages installed on the system to be removed. | no | yes | bin/omarchy-pkg-remove |

### Group `plugin`

Group description: Omarchy shell plugin and bar widget management

| ID | Command | Function | Hidden | Sudo | Source |
|---|---|---|---|---|---|
| OMA-11-250 | `omarchy-plugin-add` `[git-url] [--enable] [--yes]` | Add a shell plugin from git | no | no | bin/omarchy-plugin-add |
| OMA-11-251 | `omarchy-plugin-catalog` | Emit every first-party and user plugin manifest as JSON | yes | no | bin/omarchy-plugin-catalog |
| OMA-11-252 | `omarchy-plugin-clone` `<source-id> [--edit]` | Clone a built-in Omarchy shell plugin into your own config | no | no | bin/omarchy-plugin-clone |
| OMA-11-253 | `omarchy-plugin-disable` `<id>` | Disable a shell plugin | no | no | bin/omarchy-plugin-disable |
| OMA-11-254 | `omarchy-plugin-enable` `<id> [placement]` | Enable a shell plugin | no | no | bin/omarchy-plugin-enable |
| OMA-11-255 | `omarchy-plugin-list` `[--json]` | List discovered shell plugins | no | no | bin/omarchy-plugin-list |
| OMA-11-256 | `omarchy-plugin-remove` `[id] [--yes]` | Remove an installed shell plugin | no | no | bin/omarchy-plugin-remove |
| OMA-11-257 | `omarchy-plugin-update` `[id] [--yes]` | Update installed git-managed plugins | no | no | bin/omarchy-plugin-update |
| OMA-11-258 | `omarchy-plugin-validate` `<plugin-folder>` | Validate a plugin folder against the Omarchy plugin manifest schema | no | no | bin/omarchy-plugin-validate |

### Group `plymouth`

Group description: Plymouth boot theme management

| ID | Command | Function | Hidden | Sudo | Source |
|---|---|---|---|---|---|
| OMA-11-259 | `omarchy-plymouth-current` | Show which theme is styling the Plymouth boot screen | no | no | bin/omarchy-plymouth-current |
| OMA-11-260 | `omarchy-plymouth-list` | List themes that can style the Plymouth boot screen | no | no | bin/omarchy-plymouth-list |
| OMA-11-261 | `omarchy-plymouth-preview` `<background-hex> <text-hex> <path-to-logo.png> <output-path>` | Preview a Plymouth boot screen with custom colors and logo | no | no | bin/omarchy-plymouth-preview |
| OMA-11-262 | `omarchy-plymouth-reset` | Restore the default Omarchy Plymouth boot theme and SDDM login screen | no | yes | bin/omarchy-plymouth-reset |
| OMA-11-263 | `omarchy-plymouth-set` `<background-hex> <text-hex> <path-to-logo.png>` | Set the Plymouth boot theme colors and logo | no | yes | bin/omarchy-plymouth-set |
| OMA-11-264 | `omarchy-plymouth-set-by-theme` `<theme-name>` | Set the Plymouth boot theme from an Omarchy theme | no | yes | bin/omarchy-plymouth-set-by-theme |
| OMA-11-265 | `omarchy-plymouth-switcher` | Open the Plymouth unlock screen switcher | no | no | bin/omarchy-plymouth-switcher |

### Group `power`

Group description: Power supply detection

| ID | Command | Function | Hidden | Sudo | Source |
|---|---|---|---|---|---|
| OMA-11-266 | `omarchy-power-present` | Returns true if external power is connected. | no | no | bin/omarchy-power-present |

### Group `powerprofiles`

Group description: Power profile management

| ID | Command | Function | Hidden | Sudo | Source |
|---|---|---|---|---|---|
| OMA-11-267 | `omarchy-powerprofiles-init` | Set the correct power profile on boot based on current AC/battery state. | no | no | bin/omarchy-powerprofiles-init |
| OMA-11-268 | `omarchy-powerprofiles-list` `[--active-state]` | Returns a list of all the available power profiles on the system. | no | no | bin/omarchy-powerprofiles-list |
| OMA-11-269 | `omarchy-powerprofiles-set` `[autodetect\|ac\|battery] [power-saver\|balanced\|performance]` | Set and remember the power profile for AC or battery use | no | no | bin/omarchy-powerprofiles-set |

### Group `provision`

Group description: not determined (no `GROUP_DESCRIPTIONS` entry).

| ID | Command | Function | Hidden | Sudo | Source |
|---|---|---|---|---|---|
| OMA-11-270 | `omarchy-provision-first-run` `[--force]` | Finish first-login setup for Omarchy. | yes | no | bin/omarchy-provision-first-run |
| OMA-11-271 | `omarchy-provision-owner` | First-boot provisioning: create the user on a machine installed in deferred provisioning | yes | yes | bin/omarchy-provision-owner |
| OMA-11-272 | `omarchy-provision-user` | Finalize Omarchy user setup (runtime tweaks /etc/skel can't do) | yes | no | bin/omarchy-provision-user |

### Group `refresh`

Group description: Reset config to defaults

| ID | Command | Function | Hidden | Sudo | Source |
|---|---|---|---|---|---|
| OMA-11-273 | `omarchy-refresh-applications` | Ensure default application launchers and mise wrappers are installed. | no | no | bin/omarchy-refresh-applications |
| OMA-11-274 | `omarchy-refresh-chromium` | Refresh the ~/.config/chromium-flags.conf file from the Omarchy defaults. | no | no | bin/omarchy-refresh-chromium |
| OMA-11-275 | `omarchy-refresh-config` `<config-path>` | Copy a shipped user config from $OMARCHY_PATH/config into ~/.config (backs up your version). | no | no | bin/omarchy-refresh-config |
| OMA-11-276 | `omarchy-refresh-herdr` | Overwrite the user herdr config with the Omarchy default and reload herdr. | no | no | bin/omarchy-refresh-herdr |
| OMA-11-277 | `omarchy-refresh-hyprland` | Overwrite all the user Hyprland Lua configs in ~/.config/hypr with the Omarchy defaults. | no | no | bin/omarchy-refresh-hyprland |
| OMA-11-278 | `omarchy-refresh-hyprsunset` | Overwrite the user config for hyprsunset with the Omarchy default and restart the service. | no | no | bin/omarchy-refresh-hyprsunset |
| OMA-11-279 | `omarchy-refresh-limine` | Overwrite the user config for the Limine bootloader and rebuild it. | no | yes | bin/omarchy-refresh-limine |
| OMA-11-280 | `omarchy-refresh-pacman` | Overwrite the package configuration for /etc/pacman with the Omarchy default of using its dedicated mirrors and repositories, then update all packages. | no | yes | bin/omarchy-refresh-pacman |
| OMA-11-281 | `omarchy-refresh-plymouth` | Overwrite the user config for the Plymouth drive decryption and boot sequence with the Omarchy default and rebuild it. | no | yes | bin/omarchy-refresh-plymouth |
| OMA-11-282 | `omarchy-refresh-sddm` | Refresh the SDDM theme from default | no | yes | bin/omarchy-refresh-sddm |
| OMA-11-283 | `omarchy-refresh-shell` | Reset shell.json to Omarchy defaults | no | no | bin/omarchy-refresh-shell |
| OMA-11-284 | `omarchy-refresh-tmux` | Overwrite the user tmux config with the Omarchy default and reload tmux. | no | no | bin/omarchy-refresh-tmux |

### Group `reinstall`

Group description: Reinstall and reset workflows

| ID | Command | Function | Hidden | Sudo | Source |
|---|---|---|---|---|---|
| OMA-11-285 | `omarchy-reinstall` | Reinstall Omarchy packages and reset default configs | no | yes | bin/omarchy-reinstall |
| OMA-11-286 | `omarchy-reinstall-configs` | Reset Omarchy user configs and shipped defaults in $HOME (destructive) | no | no | bin/omarchy-reinstall-configs |
| OMA-11-287 | `omarchy-reinstall-pkgs` | Reinstall all default Omarchy packages from the stable channel | no | yes | bin/omarchy-reinstall-pkgs |

### Group `reminder`

Group description: Desktop notification reminders

| ID | Command | Function | Hidden | Sudo | Source |
|---|---|---|---|---|---|
| OMA-11-288 | `omarchy-reminder` `[-i\|--interactive] \| <minutes> [message] \| show [-j\|--json] \| clear` | Set and show lightweight desktop notification reminders | no | no | bin/omarchy-reminder |

### Group `remove`

Group description: Removal workflows

| ID | Command | Function | Hidden | Sudo | Source |
|---|---|---|---|---|---|
| OMA-11-289 | `omarchy-remove-ai-hermes` | Remove the Hermes desktop app along with the Hermes runtime it installed. | no | yes | bin/omarchy-remove-ai-hermes |
| OMA-11-290 | `omarchy-remove-ai-openclaw` | Remove the OpenClaw agent platform along with its gateway service and web app. | no | yes | bin/omarchy-remove-ai-openclaw |
| OMA-11-291 | `omarchy-remove-ai-perplexity` | Remove the Perplexity desktop app along with its runtime caches. | no | yes | bin/omarchy-remove-ai-perplexity |
| OMA-11-292 | `omarchy-remove-ai-t3-code` | Remove T3 Code along with its configuration and workspaces. | no | yes | bin/omarchy-remove-ai-t3-code |
| OMA-11-293 | `omarchy-remove-browser` `<chrome\|brave\|brave-origin\|edge\|firefox\|zen>` | Remove a supported browser and clean up Omarchy browser defaults | no | yes | bin/omarchy-remove-browser |
| OMA-11-294 | `omarchy-remove-dev-env` `<ruby\|node\|bun\|deno\|go\|php\|laravel\|symfony\|python\|elixir\|phoenix\|zig\|rust\|java\|dotnet\|ocaml\|clojure\|scala>` | Remove a development environment that was previously installed via omarchy-install-dev-env. | no | yes | bin/omarchy-remove-dev-env |
| OMA-11-295 | `omarchy-remove-gaming-battlenet` | Remove Battle.net, its Proton prefix, installed games, and desktop entry. | no | no | bin/omarchy-remove-gaming-battlenet |
| OMA-11-296 | `omarchy-remove-gaming-geforce-now` | Remove the GeForce NOW Flatpak app and its data. | no | no | bin/omarchy-remove-gaming-geforce-now |
| OMA-11-297 | `omarchy-remove-gaming-heroic` | Remove Heroic Games Launcher and its game libraries, configs, and caches. | no | yes | bin/omarchy-remove-gaming-heroic |
| OMA-11-298 | `omarchy-remove-gaming-lutris` | Remove Lutris, Wine, umu-launcher, and all their configs and caches. | no | yes | bin/omarchy-remove-gaming-lutris |
| OMA-11-299 | `omarchy-remove-gaming-minecraft` | Remove the Minecraft launcher along with its worlds, mods, and caches. | no | yes | bin/omarchy-remove-gaming-minecraft |
| OMA-11-300 | `omarchy-remove-gaming-retroarch` | Remove RetroArch, all libretro cores, and its config/saves. Leaves ~/Games/roms and ~/Games/bios alone. | no | yes | bin/omarchy-remove-gaming-retroarch |
| OMA-11-301 | `omarchy-remove-gaming-steam` | Remove Steam and all of its game libraries, configs, and caches. | no | yes | bin/omarchy-remove-gaming-steam |
| OMA-11-302 | `omarchy-remove-gaming-xbox-cloud` | Remove the Xbox Cloud Gaming web app. | no | no | bin/omarchy-remove-gaming-xbox-cloud |
| OMA-11-303 | `omarchy-remove-gaming-xbox-controllers` | Remove the xpadneo Xbox controller driver and undo its module/blacklist config. | no | yes | bin/omarchy-remove-gaming-xbox-controllers |
| OMA-11-304 | `omarchy-remove-launcher-entry` `<desktop-id> <name>` | Remove or uninstall the selected launcher entry | yes | yes | bin/omarchy-remove-launcher-entry |
| OMA-11-305 | `omarchy-remove-preinstalls` | Remove preinstalled Omarchy applications (web apps, TUIs, and selected packages). | no | no | bin/omarchy-remove-preinstalls |
| OMA-11-306 | `omarchy-remove-security-fido2` | Remove FIDO2 authentication from sudo and polkit | no | yes | bin/omarchy-remove-security-fido2 |
| OMA-11-307 | `omarchy-remove-security-fingerprint` | Remove fingerprint authentication from sudo, polkit, and lock screen | no | yes | bin/omarchy-remove-security-fingerprint |
| OMA-11-308 | `omarchy-remove-security-sshd` | Disable the OpenSSH server, remove standard firewall rules, and optionally remove authorized keys | no | yes | bin/omarchy-remove-security-sshd |
| OMA-11-309 | `omarchy-remove-security-sudoless-docker` | Disable sudoless Docker by removing your user from the docker group | no | yes | bin/omarchy-remove-security-sudoless-docker |
| OMA-11-310 | `omarchy-remove-service-1password` | Remove 1Password and its Chromium extension. | no | yes | bin/omarchy-remove-service-1password |
| OMA-11-311 | `omarchy-remove-service-dropbox` | Remove Dropbox and its bar plugin. | no | yes | bin/omarchy-remove-service-dropbox |
| OMA-11-312 | `omarchy-remove-service-sunshine` | Remove Sunshine and close Omarchy-managed Moonlight streaming ports. | no | yes | bin/omarchy-remove-service-sunshine |
| OMA-11-313 | `omarchy-remove-service-tailscale` | Remove Tailscale and its bar plugin. | no | yes | bin/omarchy-remove-service-tailscale |

### Group `restart`

Group description: Restart Omarchy components

| ID | Command | Function | Hidden | Sudo | Source |
|---|---|---|---|---|---|
| OMA-11-314 | `omarchy-restart-app` `<application-name> [application-args...]` | Restart an application by killing it and relaunching via uwsm. | no | no | bin/omarchy-restart-app |
| OMA-11-315 | `omarchy-restart-audio` | Restart audio services and recover stuck USB audio devices. | no | no | bin/omarchy-restart-audio |
| OMA-11-316 | `omarchy-restart-bluetooth` | Unblock and restart the bluetooth service. | no | no | bin/omarchy-restart-bluetooth |
| OMA-11-317 | `omarchy-restart-btop` | Reload btop configuration (used by the Omarchy theme switching). | no | no | bin/omarchy-restart-btop |
| OMA-11-318 | `omarchy-restart-gum` | Export the current theme's gum styling into the environment | yes | no | bin/omarchy-restart-gum |
| OMA-11-319 | `omarchy-restart-helix` | Reload Helix configuration | no | no | bin/omarchy-restart-helix |
| OMA-11-320 | `omarchy-restart-herdr` | Reload herdr if running with the latest configuration | no | no | bin/omarchy-restart-herdr |
| OMA-11-321 | `omarchy-restart-hyprctl` | Reload hyprland configuration (used by the Omarchy theme switching). | no | no | bin/omarchy-restart-hyprctl |
| OMA-11-322 | `omarchy-restart-hyprsunset` | Restart the hyprsunset service (used for blue light filtering/night light). | no | no | bin/omarchy-restart-hyprsunset |
| OMA-11-323 | `omarchy-restart-opencode` | Reload opencode configuration (used by the Omarchy theme switching). | no | no | bin/omarchy-restart-opencode |
| OMA-11-324 | `omarchy-restart-shell` | Restart the Omarchy shell | no | no | bin/omarchy-restart-shell |
| OMA-11-325 | `omarchy-restart-terminal` | Reload supported terminal emulators after config changes | no | no | bin/omarchy-restart-terminal |
| OMA-11-326 | `omarchy-restart-tmux` | Restart tmux if running with the latest configuration | no | no | bin/omarchy-restart-tmux |
| OMA-11-327 | `omarchy-restart-trackpad` | Reset the trackpad by unbinding and rebinding its driver. | no | yes | bin/omarchy-restart-trackpad |
| OMA-11-328 | `omarchy-restart-wifi` | Unblock and restart the Wi-Fi service. | no | no | bin/omarchy-restart-wifi |
| OMA-11-329 | `omarchy-restart-xcompose` | Restart the XCompose input method service (fcitx5) to apply new compose key settings. | no | no | bin/omarchy-restart-xcompose |

### Group `screensaver`

Group description: Screensaver branding and animation

| ID | Command | Function | Hidden | Sudo | Source |
|---|---|---|---|---|---|
| OMA-11-330 | `omarchy-screensaver` | Run the Omarchy screensaver using random effects from TTE. | no | no | bin/omarchy-screensaver |

### Group `setup`

Group description: Interactive setup wizards

| ID | Command | Function | Hidden | Sudo | Source |
|---|---|---|---|---|---|
| OMA-11-331 | `omarchy-setup-direct-boot` | Add or remove an EFI boot entry for the Omarchy UKI, allowing the system to boot directly | no | yes | bin/omarchy-setup-direct-boot |
| OMA-11-332 | `omarchy-setup-security-fido2` | Set up FIDO2 authentication for sudo and polkit | no | yes | bin/omarchy-setup-security-fido2 |
| OMA-11-333 | `omarchy-setup-security-fingerprint` | Set up fingerprint authentication for sudo, polkit, and lock screen | no | yes | bin/omarchy-setup-security-fingerprint |
| OMA-11-334 | `omarchy-setup-security-sshd` `[--key=<public-key>]` | Set up the OpenSSH server, open the firewall, and authorize an SSH key | no | yes | bin/omarchy-setup-security-sshd |
| OMA-11-335 | `omarchy-setup-security-sudoless-docker` | Enable sudoless Docker by adding your user to the docker group (root-equivalent!) | no | yes | bin/omarchy-setup-security-sudoless-docker |
| OMA-11-336 | `omarchy-system-factory-reset` | Factory-reset this machine back to its freshly-installed state | no | yes | bin/omarchy-system-factory-reset |

### Group `share`

Group description: not determined (no `GROUP_DESCRIPTIONS` entry).

| ID | Command | Function | Hidden | Sudo | Source |
|---|---|---|---|---|---|
| OMA-11-337 | `omarchy-menu-share` `<clipboard\|file\|folder> [path...]` | Share clipboard, files, or folders with LocalSend | no | no | bin/omarchy-menu-share |

### Group `shell`

Group description: Omarchy shell IPC helpers

| ID | Command | Function | Hidden | Sudo | Source |
|---|---|---|---|---|---|
| OMA-11-338 | `omarchy-shell` `[-q] <target> <method> [args...]` | Send an IPC call to the running Omarchy shell | no | no | bin/omarchy-shell |
| OMA-11-339 | `omarchy-shell-config` | Shared helpers for editing ~/.config/omarchy/shell.json (source this, don't run it). | yes | no | bin/omarchy-shell-config |

### Group `show`

Group description: not determined (no `GROUP_DESCRIPTIONS` entry).

| ID | Command | Function | Hidden | Sudo | Source |
|---|---|---|---|---|---|
| OMA-11-340 | `omarchy-show-done` | Display a "Done!" message and wait for user to press any key. | no | no | bin/omarchy-show-done |
| OMA-11-341 | `omarchy-show-logo` | Display the Omarchy logo in the terminal using green color. | no | no | bin/omarchy-show-logo |

### Group `snapshot`

Group description: System snapshots

| ID | Command | Function | Hidden | Sudo | Source |
|---|---|---|---|---|---|
| OMA-11-342 | `omarchy-snapshot` `<create\|restore>` | Create or restore system snapshots with snapper | no | yes | bin/omarchy-snapshot |

### Group `state`

Group description: not determined (no `GROUP_DESCRIPTIONS` entry).

| ID | Command | Function | Hidden | Sudo | Source |
|---|---|---|---|---|---|
| OMA-11-343 | `omarchy-state` `<set\|clear> <state-name-or-pattern>` | Manage persistent state files for Omarchy toggles and settings. | yes | no | bin/omarchy-state |

### Group `sudo`

Group description: Sudo configuration helpers

| ID | Command | Function | Hidden | Sudo | Source |
|---|---|---|---|---|---|
| OMA-11-344 | `omarchy-sudo-docker` `[--configured]` | Succeed when Docker needs sudo, fail when it can be used directly | yes | no | bin/omarchy-sudo-docker |
| OMA-11-345 | `omarchy-sudo-keepalive` | Prompt for sudo once and keep the credential alive in the background. | no | yes | bin/omarchy-sudo-keepalive |
| OMA-11-346 | `omarchy-sudo-passwordless` `[MINUTES]` | Toggle passwordless sudo for the current user. | no | yes | bin/omarchy-sudo-passwordless |

### Group `system`

Group description: System status, reboot, shutdown, logout, and lock

| ID | Command | Function | Hidden | Sudo | Source |
|---|---|---|---|---|---|
| OMA-11-347 | `omarchy-system-factory-reset-finish` | First-boot worker that finishes an omarchy-system-factory-reset reset | yes | yes | bin/omarchy-system-factory-reset-finish |
| OMA-11-348 | `omarchy-system-lid-close` | Lock and reconcile displays when the laptop lid closes | yes | no | bin/omarchy-system-lid-close |
| OMA-11-349 | `omarchy-system-lock` | Lock the computer and turn off the display | no | no | bin/omarchy-system-lock |
| OMA-11-350 | `omarchy-system-logout` | Log out after closing application windows | no | no | bin/omarchy-system-logout |
| OMA-11-351 | `omarchy-system-reboot` | Reboot after closing application windows | no | no | bin/omarchy-system-reboot |
| OMA-11-352 | `omarchy-system-shutdown` | Shut down after closing application windows | no | no | bin/omarchy-system-shutdown |
| OMA-11-353 | `omarchy-system-sleep-lock` | Lock before suspend and wait for the session lock to become secure | yes | no | bin/omarchy-system-sleep-lock |
| OMA-11-354 | `omarchy-system-sleep-monitor` | Monitor sleep preparation and lock before suspend | yes | no | bin/omarchy-system-sleep-monitor |
| OMA-11-355 | `omarchy-system-stats` `[--bar-widget]` | Print CPU and memory stats for the shell | no | no | bin/omarchy-system-stats |
| OMA-11-356 | `omarchy-system-wake` | Wake displays and restore brightness after idle | no | no | bin/omarchy-system-wake |

### Group `tailscale`

Group description: Tailscale helpers

| ID | Command | Function | Hidden | Sudo | Source |
|---|---|---|---|---|---|
| OMA-11-357 | `omarchy-tailscale-receive` `[--once] [directory]` | Save incoming Taildrop files and announce them | no | no | bin/omarchy-tailscale-receive |
| OMA-11-358 | `omarchy-tailscale-send` `<machine> [file...]` | Send files to a machine on your tailnet with Taildrop | no | no | bin/omarchy-tailscale-send |

### Group `theme`

Group description: Theme management

| ID | Command | Function | Hidden | Sudo | Source |
|---|---|---|---|---|---|
| OMA-11-359 | `omarchy-theme-bg-cache` | Cache background switcher thumbnails for the current theme | no | no | bin/omarchy-theme-bg-cache |
| OMA-11-360 | `omarchy-theme-bg-current` | Show current background | no | no | bin/omarchy-theme-bg-current |
| OMA-11-361 | `omarchy-theme-bg-install` | Open the current theme's user background folder | no | no | bin/omarchy-theme-bg-install |
| OMA-11-362 | `omarchy-theme-bg-next` | Cycle to the next background for the current theme | no | no | bin/omarchy-theme-bg-next |
| OMA-11-363 | `omarchy-theme-bg-set` `<path-to-image>` | Set the current background image | no | no | bin/omarchy-theme-bg-set |
| OMA-11-364 | `omarchy-theme-bg-switcher` | Open the Omarchy background switcher | no | no | bin/omarchy-theme-bg-switcher |
| OMA-11-365 | `omarchy-theme-color` `[--file <colors.toml>] (--all \| --raw \| <key> [fallback])` | Resolve semantic colors from an Omarchy theme colors.toml | yes | no | bin/omarchy-theme-color |
| OMA-11-366 | `omarchy-theme-colors-from-alacritty` `<theme-dir>` | Generate a theme's colors.toml from its alacritty.toml palette | yes | no | bin/omarchy-theme-colors-from-alacritty |
| OMA-11-367 | `omarchy-theme-current` | Show current theme | no | no | bin/omarchy-theme-current |
| OMA-11-368 | `omarchy-theme-dir` `<theme-name>` | Print the directory holding a theme, preferring a user-installed copy | no | no | bin/omarchy-theme-dir |
| OMA-11-369 | `omarchy-theme-extras` | List the user-installed themes that came from a git clone | no | no | bin/omarchy-theme-extras |
| OMA-11-370 | `omarchy-theme-install` `[git-repo-url]` | Install a theme from a git repository | no | no | bin/omarchy-theme-install |
| OMA-11-371 | `omarchy-theme-list` | List available themes | no | no | bin/omarchy-theme-list |
| OMA-11-372 | `omarchy-theme-osc` | Print OSC sequences for an Omarchy color theme | yes | no | bin/omarchy-theme-osc |
| OMA-11-373 | `omarchy-theme-refresh` | Refresh the current theme from its templates. | no | no | bin/omarchy-theme-refresh |
| OMA-11-374 | `omarchy-theme-remove` `[theme-name]` | Remove a user-installed theme | no | no | bin/omarchy-theme-remove |
| OMA-11-375 | `omarchy-theme-set` `<theme-name>` | Apply an Omarchy theme | no | no | bin/omarchy-theme-set |
| OMA-11-376 | `omarchy-theme-set-browser` | Apply the current theme color to Chromium, Chrome, Edge, and Brave | yes | no | bin/omarchy-theme-set-browser |
| OMA-11-377 | `omarchy-theme-set-browser-policy` `<rrggbb>` | Write the current theme color into the browser policy directories | yes | no | bin/omarchy-theme-set-browser-policy |
| OMA-11-378 | `omarchy-theme-set-claude` `[--activate]` | Sync the generated Omarchy theme to Claude Code | yes | no | bin/omarchy-theme-set-claude |
| OMA-11-379 | `omarchy-theme-set-foot` | Apply current Omarchy theme colors to running Foot terminals | yes | no | bin/omarchy-theme-set-foot |
| OMA-11-380 | `omarchy-theme-set-gnome` | Apply the current theme to GNOME color mode and icon settings | yes | no | bin/omarchy-theme-set-gnome |
| OMA-11-381 | `omarchy-theme-set-hermes` `[--activate] [--wait]` | Sync the generated Omarchy theme to Hermes as a skin | yes | no | bin/omarchy-theme-set-hermes |
| OMA-11-382 | `omarchy-theme-set-keyboard` | Apply the current theme keyboard color to supported keyboards | yes | no | bin/omarchy-theme-set-keyboard |
| OMA-11-383 | `omarchy-theme-set-keyboard-asus-rog` | Apply the current theme keyboard color to ASUS ROG keyboards | yes | no | bin/omarchy-theme-set-keyboard-asus-rog |
| OMA-11-384 | `omarchy-theme-set-keyboard-f16` | Apply the current theme keyboard color to Framework Laptop 16 keyboards | yes | no | bin/omarchy-theme-set-keyboard-f16 |
| OMA-11-385 | `omarchy-theme-set-obsidian` | Sync Omarchy theme to all Obsidian vaults | yes | no | bin/omarchy-theme-set-obsidian |
| OMA-11-386 | `omarchy-theme-set-pi` `[--activate]` | Sync the generated Omarchy Pi theme | yes | no | bin/omarchy-theme-set-pi |
| OMA-11-387 | `omarchy-theme-set-t3code` | Sync the generated Omarchy theme to T3 Code | yes | no | bin/omarchy-theme-set-t3code |
| OMA-11-388 | `omarchy-theme-set-templates` | Generate themed config files from Omarchy templates | yes | no | bin/omarchy-theme-set-templates |
| OMA-11-389 | `omarchy-theme-set-tmux` | Sync current Omarchy theme environment into tmux | yes | no | bin/omarchy-theme-set-tmux |
| OMA-11-390 | `omarchy-theme-set-vscode` | Sync Omarchy theme to VS Code, VSCodium, and Cursor | yes | no | bin/omarchy-theme-set-vscode |
| OMA-11-391 | `omarchy-theme-switcher` | Open the Omarchy theme switcher | no | no | bin/omarchy-theme-switcher |
| OMA-11-392 | `omarchy-theme-update` | Update user-installed git themes | no | no | bin/omarchy-theme-update |

### Group `toggle`

Group description: Toggle Omarchy features

| ID | Command | Function | Hidden | Sudo | Source |
|---|---|---|---|---|---|
| OMA-11-393 | `omarchy-toggle` `<flag-name> [toggle\|on\|off]` | Toggle Omarchy features between enabled and disabled | no | no | bin/omarchy-toggle |
| OMA-11-394 | `omarchy-toggle-bar` `[toggle\|on\|off]` | Toggle bar visibility without killing the Omarchy shell | no | no | bin/omarchy-toggle-bar |
| OMA-11-395 | `omarchy-toggle-crash-capture` | Toggle crash capture notifications | no | no | bin/omarchy-toggle-crash-capture |
| OMA-11-396 | `omarchy-toggle-enabled` `<flag-name>` | Check if a toggle is enabled (flag file exists) | no | no | bin/omarchy-toggle-enabled |
| OMA-11-397 | `omarchy-toggle-hybrid-gpu` | Toggle dedicated vs integrated GPU mode via supergfxd (for hybrid gpu laptops, like Asus G14). | no | yes | bin/omarchy-toggle-hybrid-gpu |
| OMA-11-398 | `omarchy-toggle-idle` `[toggle\|stay-awake\|allow-idle\|status]` | Toggle idle behavior so the system either idles normally or stays awake | no | no | bin/omarchy-toggle-idle |
| OMA-11-399 | `omarchy-toggle-input-device` `<touchpad\|touchscreen> [on\|off\|toggle]` | Enable, disable, or toggle a Hyprland input device | yes | no | bin/omarchy-toggle-input-device |
| OMA-11-400 | `omarchy-toggle-nightlight` `[--status]` | Toggle nightlight screen temperature | no | no | bin/omarchy-toggle-nightlight |
| OMA-11-401 | `omarchy-toggle-notification-silencing` | Toggle notification do-not-disturb mode | no | no | bin/omarchy-toggle-notification-silencing |
| OMA-11-402 | `omarchy-toggle-screensaver` | Toggle screensaver availability | no | no | bin/omarchy-toggle-screensaver |
| OMA-11-403 | `omarchy-toggle-suspend` | Toggle suspend availability in the system menu | no | no | bin/omarchy-toggle-suspend |
| OMA-11-404 | `omarchy-toggle-touchpad` `[on\|off\|toggle]` | Enable, disable, or toggle the touchpad | no | no | bin/omarchy-toggle-touchpad |
| OMA-11-405 | `omarchy-toggle-touchscreen` `[on\|off\|toggle]` | Enable, disable, or toggle the touch functionality of the screen | no | no | bin/omarchy-toggle-touchscreen |

### Group `transcode`

Group description: Image and video transcoding

| ID | Command | Function | Hidden | Sudo | Source |
|---|---|---|---|---|---|
| OMA-11-406 | `omarchy-transcode` `[--path path] [input] [format] [resolution]` | Transcode pictures and videos for sharing | no | no | bin/omarchy-transcode |
| OMA-11-407 | `omarchy-transcode-ascii` `<input-image.svg\|png> <output-path> [--width <columns>] [--height <rows>] [--mode <braille\|block>] [--threshold <percent>] [--invert]` | Transcode an image into ASCII/Unicode art text | no | no | bin/omarchy-transcode-ascii |

### Group `tui`

Group description: Terminal UI launchers

| ID | Command | Function | Hidden | Sudo | Source |
|---|---|---|---|---|---|
| OMA-11-408 | `omarchy-tui-install` `[name command window-style icon-url-or-name]` | Create a desktop launcher for a terminal UI app | no | no | bin/omarchy-tui-install |
| OMA-11-409 | `omarchy-tui-remove` `[name]` | Remove a terminal UI desktop launcher | no | no | bin/omarchy-tui-remove |
| OMA-11-410 | `omarchy-tui-remove-all` | Remove all TUIs installed via omarchy-tui-install. | no | no | bin/omarchy-tui-remove-all |

### Group `update`

Group description: Omarchy and system updates

| ID | Command | Function | Hidden | Sudo | Source |
|---|---|---|---|---|---|
| OMA-11-411 | `omarchy-update` `[-y]` | Update Omarchy and system packages | no | yes | bin/omarchy-update |
| OMA-11-412 | `omarchy-update-analyze-logs` | Check the update log for known failure conditions | no | no | bin/omarchy-update-analyze-logs |
| OMA-11-413 | `omarchy-update-aur-pkgs` | Update AUR packages if any are installed | no | no | bin/omarchy-update-aur-pkgs |
| OMA-11-414 | `omarchy-update-available` | Check whether Omarchy updates are available. | no | no | bin/omarchy-update-available |
| OMA-11-415 | `omarchy-update-confirm` | Prompt for confirmation before starting an update | no | no | bin/omarchy-update-confirm |
| OMA-11-416 | `omarchy-update-dev` | Update the active Omarchy dev checkout | no | no | bin/omarchy-update-dev |
| OMA-11-417 | `omarchy-update-firmware` | Update system firmware using fwupd. Ensures the fwupd EFI binary is installed | no | yes | bin/omarchy-update-firmware |
| OMA-11-418 | `omarchy-update-keyring` | Ensure the Omarchy and Arch keyring packages are installed and populated | no | yes | bin/omarchy-update-keyring |
| OMA-11-419 | `omarchy-update-lock` `<held\|run> [command] [args...]` | Run a command while holding the Omarchy update lock | yes | no | bin/omarchy-update-lock |
| OMA-11-420 | `omarchy-update-mise` | Update mise-managed tools | no | no | bin/omarchy-update-mise |
| OMA-11-421 | `omarchy-update-orphan-pkgs` | Review and optionally remove orphaned system packages after updates | no | yes | bin/omarchy-update-orphan-pkgs |
| OMA-11-422 | `omarchy-update-pacman-guard` | Prevent direct pacman system upgrades from bypassing omarchy update. | yes | no | bin/omarchy-update-pacman-guard |
| OMA-11-423 | `omarchy-update-pkg-prune` | Prune superseded versions from the pacman package cache | no | yes | bin/omarchy-update-pkg-prune |
| OMA-11-424 | `omarchy-update-requires-free-space` | Check free disk space required for an update | yes | no | bin/omarchy-update-requires-free-space |
| OMA-11-425 | `omarchy-update-restart` | Prompt for required reboot or service restarts after updates | no | no | bin/omarchy-update-restart |
| OMA-11-426 | `omarchy-update-status` | Refresh the shell update status | yes | no | bin/omarchy-update-status |
| OMA-11-427 | `omarchy-update-stay-awake` `<start\|stop>` | Manage sleep and idle inhibition during an update | yes | no | bin/omarchy-update-stay-awake |
| OMA-11-428 | `omarchy-update-system-pkgs` | Update system packages with pacman | no | yes | bin/omarchy-update-system-pkgs |
| OMA-11-429 | `omarchy-update-system-pkgs-when-conflicted` | Retry a system package update that hit a conflict | yes | no | bin/omarchy-update-system-pkgs-when-conflicted |
| OMA-11-430 | `omarchy-update-time` | Restart system time synchronization | no | yes | bin/omarchy-update-time |
| OMA-11-431 | `omarchy-update-user-notify` | Compatibility wrapper for omarchy-migrate-notify. | yes | no | bin/omarchy-update-user-notify |

### Group `upgrade`

Group description: not determined (no `GROUP_DESCRIPTIONS` entry).

| ID | Command | Function | Hidden | Sudo | Source |
|---|---|---|---|---|---|
| OMA-11-432 | `omarchy-upgrade-to-quattro` `[--yes] [--reboot] [--dev] [--channel stable\|rc\|edge] [--user USER]` | Upgrade a legacy Omarchy install to the package-backed Omarchy quattro layout. | no | yes | bin/omarchy-upgrade-to-quattro |

### Group `upload`

Group description: not determined (no `GROUP_DESCRIPTIONS` entry).

| ID | Command | Function | Hidden | Sudo | Source |
|---|---|---|---|---|---|
| OMA-11-433 | `omarchy-upload-log` `<log-file>` | Upload logs to logs.omarchy.org | yes | no | bin/omarchy-upload-log |

### Group `version`

Group description: Version and channel information

| ID | Command | Function | Hidden | Sudo | Source |
|---|---|---|---|---|---|
| OMA-11-434 | `omarchy-version` | Print the installed Omarchy version | no | no | bin/omarchy-version |
| OMA-11-435 | `omarchy-version-branch` | Print the active Omarchy dev-link git branch | yes | no | bin/omarchy-version-branch |
| OMA-11-436 | `omarchy-version-channel` | Print the active Omarchy mirror and package channel | no | no | bin/omarchy-version-channel |
| OMA-11-437 | `omarchy-version-pkgs` | Print when system packages were last upgraded | no | no | bin/omarchy-version-pkgs |

### Group `voxtype`

Group description: Voxtype dictation

| ID | Command | Function | Hidden | Sudo | Source |
|---|---|---|---|---|---|
| OMA-11-438 | `omarchy-voxtype-config` | Open Voxtype configuration | no | no | bin/omarchy-voxtype-config |
| OMA-11-439 | `omarchy-voxtype-install` | Install and configure Voxtype dictation | no | yes | bin/omarchy-voxtype-install |
| OMA-11-440 | `omarchy-voxtype-model` | Open Voxtype AI model setup | no | no | bin/omarchy-voxtype-model |
| OMA-11-441 | `omarchy-voxtype-remove` | Remove Voxtype dictation and its configuration | no | yes | bin/omarchy-voxtype-remove |
| OMA-11-442 | `omarchy-voxtype-status` | Stream voxtype --follow status as bar-friendly JSON | no | no | bin/omarchy-voxtype-status |

### Group `weather`

Group description: Weather status

| ID | Command | Function | Hidden | Sudo | Source |
|---|---|---|---|---|---|
| OMA-11-443 | `omarchy-weather-icon` | Returns a weather condition icon, adjusted for live sunrise and sunset. | no | no | bin/omarchy-weather-icon |
| OMA-11-444 | `omarchy-weather-location` | Show or set the location used for weather reports | no | no | bin/omarchy-weather-location |
| OMA-11-445 | `omarchy-weather-status` | Returns a formatted weather status string with temperature and wind speed. | no | no | bin/omarchy-weather-status |

### Group `webapp`

Group description: Web app launchers

| ID | Command | Function | Hidden | Sudo | Source |
|---|---|---|---|---|---|
| OMA-11-446 | `omarchy-webapp-handler-hey` `[url]` | Open HEY webmail and translate mailto links | no | no | bin/omarchy-webapp-handler-hey |
| OMA-11-447 | `omarchy-webapp-handler-zoom` `[url]` | Open Zoom web meetings from browser protocol links | no | no | bin/omarchy-webapp-handler-zoom |
| OMA-11-448 | `omarchy-webapp-install` `[name url icon-url-or-name [custom-exec] [mime-types]]` | Create a desktop launcher for a web app | no | no | bin/omarchy-webapp-install |
| OMA-11-449 | `omarchy-webapp-remove` `[name]` | Remove a web app desktop launcher | no | no | bin/omarchy-webapp-remove |
| OMA-11-450 | `omarchy-webapp-remove-all` | Remove all web apps installed via omarchy-webapp-install. | no | no | bin/omarchy-webapp-remove-all |

### Group `windows`

Group description: Windows VM management

| ID | Command | Function | Hidden | Sudo | Source |
|---|---|---|---|---|---|
| OMA-11-451 | `omarchy-windows-vm` `<install\|remove\|launch\|stop\|status> [options]` | Install, launch, stop, inspect, or remove the Windows VM | no | yes | bin/omarchy-windows-vm |

## 12. Applications and web apps

### Default applications

| ID | Role | Application | Source |
|---|---|---|---|
| OMA-12-001 | Terminal | foot | default/xdg-terminal-exec |
| OMA-12-002 | Browser | Chromium | bin/omarchy-provision-user |
| OMA-12-003 | Editor | Neovim (`omarchy-nvim`) | bin/omarchy-launch-editor |
| OMA-12-004 | File manager | Nautilus | default/applications/mimeapps.list |
| OMA-12-005 | Image viewer | imv | applications/imv.desktop |
| OMA-12-006 | Media player | mpv | applications/mpv.desktop |
| OMA-12-007 | PDF viewer | Evince | default/applications/mimeapps.list |
| OMA-12-008 | Screenshot editor | tensaku | bin/omarchy-capture-screenshot |
| OMA-12-009 | Screen recorder | gpu-screen-recorder | bin/omarchy-capture-screenrecording |
| OMA-12-010 | OCR | tesseract | bin/omarchy-capture-text |
| OMA-12-011 | QR scan | zbar (`zbarimg`) | install/omarchy-base.packages |
| OMA-12-012 | System monitor | btop | default/hypr/bindings/utilities.lua |
| OMA-12-013 | Calculator | omacalc | default/hypr/bindings/utilities.lua |

### Shipped desktop entries

| ID | Name | Type | Exec | Source |
|---|---|---|---|---|
| OMA-12-014 | Basecamp | web app | `omarchy-launch-webapp https://launchpad.37signals.com` | applications/Basecamp.desktop |
| OMA-12-015 | Discord | web app | `omarchy-launch-webapp https://discord.com/channels/@me` | applications/Discord.desktop |
| OMA-12-016 | Disk Usage | TUI | `xdg-terminal-exec --app-id=TUI.float -e bash -c "dua i /"` | applications/Disk Usage.desktop |
| OMA-12-017 | Docker | TUI | `xdg-terminal-exec --app-id=TUI.tile -e omarchy-launch-docker-tui` | applications/Docker.desktop |
| OMA-12-018 | Google Contacts | web app | `omarchy-launch-webapp https://contacts.google.com/` | applications/Google Contacts.desktop |
| OMA-12-019 | Google Maps | web app | `omarchy-launch-webapp https://maps.google.com` | applications/Google Maps.desktop |
| OMA-12-020 | Google Messages | web app | `omarchy-launch-webapp https://messages.google.com/web/conversations` | applications/Google Messages.desktop |
| OMA-12-021 | Google Photos | web app | `omarchy-launch-webapp https://photos.google.com/` | applications/Google Photos.desktop |
| OMA-12-022 | HEY | web app | `omarchy-webapp-handler-hey %u` | applications/HEY.desktop |
| OMA-12-023 | WhatsApp | web app | `omarchy-launch-webapp https://web.whatsapp.com/` | applications/WhatsApp.desktop |
| OMA-12-024 | X | web app | `omarchy-launch-webapp https://x.com/` | applications/X.desktop |
| OMA-12-025 | YouTube | web app | `omarchy-launch-webapp https://youtube.com/` | applications/YouTube.desktop |
| OMA-12-026 | Zoom | web app | `omarchy-webapp-handler-zoom %u` | applications/Zoom.desktop |
| OMA-12-027 | Foot | application | `foot` | applications/foot.desktop |
| OMA-12-028 | Image Viewer | application | `imv %F` | applications/imv.desktop |
| OMA-12-029 | Media Player | application | `mpv --player-operation-mode=pseudo-gui -- %U` | applications/mpv.desktop |
| OMA-12-030 | Browser | application | `omarchy-launch-browser %U` | applications/omarchy-browser.desktop |

### Web app procedure

| ID | Requirement | Source |
|---|---|---|
| OMA-12-031 | `omarchy-launch-webapp <url>` must open the URL in a Chromium app window. | bin/omarchy-launch-webapp |
| OMA-12-032 | `omarchy-launch-or-focus-webapp <name> <url>` must focus an existing window or open a new one. | bin/omarchy-launch-or-focus-webapp |
| OMA-12-033 | `omarchy-webapp-install` must create a desktop entry and an icon for a web app. | bin/omarchy-webapp-install |
| OMA-12-034 | `omarchy-webapp-remove` and `omarchy-webapp-remove-all` must remove web apps. | bin/omarchy-webapp-remove* |
| OMA-12-035 | `omarchy-webapp-handler-hey` and `omarchy-webapp-handler-zoom` must handle `mailto` and Zoom URLs. | bin/omarchy-webapp-handler-* |

### TUIs

| ID | Requirement | Source |
|---|---|---|
| OMA-12-036 | `omarchy-tui-install` must create a desktop entry for a terminal application. | bin/omarchy-tui-install |
| OMA-12-037 | A TUI window must use the app ID `TUI.float` or `TUI.tile`. | applications/Docker.desktop; applications/Disk Usage.desktop |

### Chromium

| ID | Requirement | Source |
|---|---|---|
| OMA-12-038 | Chromium must run with Wayland, `gnome-libsecret` and touchpad overscroll navigation. | config/chromium-flags.conf |
| OMA-12-039 | Chromium must load the extensions copy-url, yt-dlp and whatsapp-slim. | config/chromium-flags.conf |
| OMA-12-040 | Chromium must not check for the default browser. | config/chromium-flags.conf; default/chromium |
| OMA-12-041 | The managed policy must set `DefaultBrowserSettingEnabled=false`. | default/chromium |
| OMA-12-042 | The native messaging hosts `copy_url` and `ytdlp` must be installed. | install/user/chromium.sh |

### Preinstalls

| ID | Requirement | Source |
|---|---|---|
| OMA-12-043 | `omarchy-remove-preinstalls` must remove the packages aether, cliamp, libreoffice-fresh, xournalpp, pinta, obsidian, obs-studio, kdenlive, moonlight-qt, lazydocker, omacut, omacalc and omawrite. | bin/omarchy-remove-preinstalls |
| OMA-12-044 | `omarchy-remove-preinstalls` must also remove the web apps, TUIs and `~/.local/bin` mise wrappers. | bin/omarchy-remove-preinstalls |
| OMA-12-045 | `omarchy-remove-preinstalls` must create `preinstalls-removed`, which turns off the preinstall bindings. | bin/omarchy-remove-preinstalls |
| OMA-12-046 | `omarchy-install-preinstalls` must restore the packages and launchers and then delete `preinstalls-removed`. | bin/omarchy-install-preinstalls |

### AI tools

| ID | Requirement | Source |
|---|---|---|
| OMA-12-047 | mise must install the AI CLIs in section 7 and wrap them in `~/.local/bin`. | install/user/mise.sh |
| OMA-12-048 | `omarchy-agent` must launch the default coding agent in a terminal. | bin/omarchy-agent |
| OMA-12-049 | The optional installers are the `install` group commands in section 11. | bin/omarchy-install-* |

## 13. Update and package management

### Update procedure (`omarchy-update`)

| ID | Requirement | Source |
|---|---|---|
| OMA-13-001 | `omarchy-update` must accept `-y` to skip the confirmation. | bin/omarchy-update |
| OMA-13-002 | `omarchy-update` must record its output with `script` to `/tmp/omarchy-update.log`. | bin/omarchy-update |
| OMA-13-003 | `omarchy-update` must hold the update lock through `omarchy-update-lock`. | bin/omarchy-update-lock |

| ID | Step | Action | Source |
|---|---|---|---|
| OMA-13-004 | 1. `omarchy-update-requires-free-space` | Require 10 GiB free. `OMARCHY_UPDATE_FORCE` bypasses the check. | bin/omarchy-update |
| OMA-13-005 | 2. `omarchy-update-confirm` | Ask the user to confirm. | bin/omarchy-update |
| OMA-13-006 | 3. `omarchy-update-pkg-prune` | Prune packages. | bin/omarchy-update |
| OMA-13-007 | 4. `omarchy-snapshot create` | Make a snapshot. | bin/omarchy-update |
| OMA-13-008 | 5. `omarchy-update-stay-awake start` | Prevent sleep. | bin/omarchy-update |
| OMA-13-009 | 6. `omarchy-update-dev` | Update the dev checkout when in the dev channel. | bin/omarchy-update |
| OMA-13-010 | 7. `omarchy-update-keyring` | Update `omarchy-keyring`. | bin/omarchy-update |
| OMA-13-011 | 8. `omarchy-update-system-pkgs` | Run `sudo env OMARCHY_UPDATE_PACMAN=1 pacman -Syu --noconfirm --overwrite '/usr/share/omarchy/*'`. Retry on a conflict. | bin/omarchy-update |
| OMA-13-012 | 9. `omarchy-migrate` | Run pending migrations. | bin/omarchy-update |
| OMA-13-013 | 10. `omarchy-hook post-update` | Run the `post-update` hook. | bin/omarchy-update |
| OMA-13-014 | 11. `omarchy-update-aur-pkgs` | Run `yay -Sua`. | bin/omarchy-update |
| OMA-13-015 | 12. `omarchy-update-mise` | Run `mise up`. | bin/omarchy-update |
| OMA-13-016 | 13. `omarchy-update-orphan-pkgs` | Show orphan packages. Only ask, do not remove. | bin/omarchy-update |
| OMA-13-017 | 14. `omarchy-update-analyze-logs` | Analyze the update log. | bin/omarchy-update |
| OMA-13-018 | 15. `omarchy-update-status` | Refresh the update status. | bin/omarchy-update |
| OMA-13-019 | 16. `omarchy-update-stay-awake stop` | Allow sleep again. | bin/omarchy-update |
| OMA-13-020 | 17. `omarchy-update-restart` | Ask for a reboot or restart from the markers. Always restart the shell. | bin/omarchy-update |

### Package guard

| ID | Requirement | Source |
|---|---|---|
| OMA-13-021 | The ALPM hook `00-omarchy-update-guard` must stop a direct `pacman -Syu`. | default/libalpm/; bin/omarchy-update-pacman-guard |
| OMA-13-022 | `OMARCHY_ALLOW_DIRECT_PACMAN=1` must bypass the guard. | default/libalpm/ |
| OMA-13-023 | The ALPM hooks must pause Hyprland config reload during a transaction and resume it after. | default/libalpm/ |

### Repositories

| ID | Requirement | Source |
|---|---|---|
| OMA-13-024 | `pacman.conf` must list the `[omarchy]` repository at `https://pkgs.omarchy.org/{stable\|edge}/$arch` before `core`, `extra` and `multilib`. | default/pacman/ |
| OMA-13-025 | `pacman.conf` must set `SigLevel = Required DatabaseOptional` and `ParallelDownloads = 5`. | default/pacman/ |
| OMA-13-026 | The mirror lists must be stable-mirror, rc-mirror and `mirror.omarchy.org` for edge. | default/pacman/ |
| OMA-13-027 | The OPR signing key must be `40DFB630FF42BCFFB047046CF0134EE680CAC571`. | bin/omarchy-update-keyring |
| OMA-13-028 | T2 Macs must add the `[arch-mact2]` repository. | install/hardware/pacman.sh |

### Channels

| ID | Channel | Packages | Source |
|---|---|---|---|
| OMA-13-029 | stable | `omarchy`, `omarchy-settings` | bin/omarchy-channel-set |
| OMA-13-030 | rc | `omarchy`, `omarchy-settings` from the rc mirror | bin/omarchy-channel-set |
| OMA-13-031 | edge | `omarchy-dev`, `omarchy-settings-dev` | bin/omarchy-channel-set |
| OMA-13-032 | dev | Clone `github.com/omacom/omarchy` to `~/omarchy` and run the dev link | bin/omarchy-channel-set; bin/omarchy-dev-link |

### Other update paths

| ID | Requirement | Source |
|---|---|---|
| OMA-13-033 | `omarchy-update-firmware` must update firmware through `fwupd`. | bin/omarchy-update-firmware |
| OMA-13-034 | The install menu must list the optional installers. See the `install.*` entries in section 8. | default/omarchy/omarchy-menu.jsonc |
| OMA-13-035 | `omarchy-update-available` must report whether an update exists. | bin/omarchy-update-available |

## 14. Hardware support

### System quirks (`install/hardware/all.sh`)

| ID | Script | Hardware | Action | Source |
|---|---|---|---|---|
| OMA-14-001 | `asus-rog.sh` | ASUS ROG | Install `asusctl`. | install/hardware/asus-rog.sh |
| OMA-14-002 | `framework16.sh` | Framework 16 | Install `qmk-hid`. | install/hardware/framework16.sh |
| OMA-14-003 | `dell-xps-touchpad-haptics.sh` | Dell XPS with haptic touchpad | Install `dell-xps-touchpad-haptics`. | install/hardware/dell-xps-touchpad-haptics.sh |
| OMA-14-004 | `surface.sh` | Microsoft Surface | Install `linux-firmware-marvell`. | install/hardware/surface.sh |
| OMA-14-005 | `network.sh` | All | Turn off iwd and systemd-networkd. Mask networkd-wait-online. Move stock `20-*.network` files. | install/hardware/network.sh |
| OMA-14-006 | `set-wireless-regdom.sh` | All | Set `WIRELESS_REGDOM` from the timezone. | install/hardware/set-wireless-regdom.sh |
| OMA-14-007 | `fix-fkeys.sh` | Apple keyboards | Set `options hid_apple fnmode=2`. | install/hardware/fix-fkeys.sh |
| OMA-14-008 | `fix-synaptic-touchpad.sh` | Synaptics touchpads | Run `modprobe psmouse synaptics_intertouch=1` at runtime. | install/hardware/fix-synaptic-touchpad.sh |
| OMA-14-009 | `bluetooth.sh` | All | Enable `bluetooth.service`. Keep `AutoEnable` at the stock value. | install/hardware/bluetooth.sh |
| OMA-14-010 | `nvidia.sh` | NVIDIA GPU with GSP | Install `nvidia-open-dkms`, `nvidia-utils`, `lib32-nvidia-utils` and `libva-nvidia-driver`. | install/hardware/nvidia.sh |
| OMA-14-011 | `nvidia.sh` | NVIDIA GPU without GSP | Install the `nvidia-580xx` variants. | install/hardware/nvidia.sh |
| OMA-14-012 | `nvidia.sh` | NVIDIA GPU | Set `options nvidia_drm modeset=1`. Add `nvidia nvidia_modeset nvidia_uvm nvidia_drm` to the initramfs. | install/hardware/nvidia.sh |
| OMA-14-013 | `vulkan.sh` | Intel, AMD or Apple GPU | Install `vulkan-intel`, `vulkan-radeon` or `vulkan-asahi` from `lspci`. | install/hardware/vulkan.sh |
| OMA-14-014 | `intel/video-acceleration.sh` | Intel HD/UHD/Xe/Iris/Arc/Panther Lake | Install `intel-media-driver`, `libvpl` and `vpl-gpu-rt`. | install/hardware/intel/video-acceleration.sh |
| OMA-14-015 | `intel/video-acceleration.sh` | Intel GMA | Install `libva-intel-driver`. | install/hardware/intel/video-acceleration.sh |
| OMA-14-016 | `intel/lpmd.sh` | Intel CPU models 151/154/170/172/183/186/189/191/204 with a battery | Install and enable `intel-lpmd`. | install/hardware/intel/lpmd.sh |
| OMA-14-017 | `intel/thermald.sh` | Intel CPU model 42 or later with a battery | Install and enable `thermald`. | install/hardware/intel/thermald.sh |
| OMA-14-018 | `intel/ipu7-camera.sh` | Intel IPU7 camera (`OVTI08F4`) | Install `intel-ipu7-camera`. | install/hardware/intel/ipu7-camera.sh |
| OMA-14-019 | `intel/fred.sh` | Intel Panther Lake | Add `fred=on` to the kernel command line. | install/hardware/intel/fred.sh |
| OMA-14-020 | `intel/fix-wifi7-eht.sh` | Intel Wi-Fi 7 `8086:e440` or `8086:272b` | Set `iwlwifi disable_11be=Y`. | install/hardware/intel/fix-wifi7-eht.sh |
| OMA-14-021 | `intel/sof-firmware.sh` | Intel SOF audio | Install `sof-firmware`. | install/hardware/intel/sof-firmware.sh |
| OMA-14-022 | `dell-xps13-ptl-speaker-firmware.sh` | Dell XPS 13 Panther Lake | Install `linux-firmware-cirrus-dx13260`. | install/hardware/dell-xps13-ptl-speaker-firmware.sh |
| OMA-14-023 | `asus/fix-asus-ptl-display-backlight.sh` | ASUS B9406 or UX5406AA | Add `xe.enable_dpcd_backlight=1`. | install/hardware/asus/fix-asus-ptl-display-backlight.sh |
| OMA-14-024 | `asus/fix-asus-ptl-b9406-display.sh` | ASUS B9406 | Add `xe.enable_panel_replay=0`. | install/hardware/asus/fix-asus-ptl-b9406-display.sh |
| OMA-14-025 | `asus/fix-asus-ptl-b9406-touchpad.sh` | ASUS B9406 | Add a libinput quirk that masks the pressure axes. | install/hardware/asus/fix-asus-ptl-b9406-touchpad.sh |
| OMA-14-026 | `asus/fix-z13-touchpad.sh` | ASUS ROG Flow Z13 (GZ302) | Add a udev rule that marks the touchpad internal. | install/hardware/asus/fix-z13-touchpad.sh |
| OMA-14-027 | `framework/qmk-hid.sh` | Framework 16 | Add the udev rule `50-framework16-qmk-hid.rules`. | install/hardware/framework/qmk-hid.sh |
| OMA-14-028 | `apple/fix-spi-keyboard.sh` | MacBook with SPI keyboard | Install `macbook12-spi-driver-dkms` and add the initramfs modules. | install/hardware/apple/fix-spi-keyboard.sh |
| OMA-14-029 | `apple/fix-suspend-nvme.sh` | Apple NVMe | Enable `omarchy-nvme-suspend-fix.service`, which sets `d3cold_allowed=0`. | install/hardware/apple/fix-suspend-nvme.sh |
| OMA-14-030 | `apple/fix-t2.sh` | Apple T2 (`106b:1801`, `106b:1802`) | Install `linux-t2`, `linux-t2-headers`, `apple-t2-audio-config`, `apple-bcm-firmware-fetcher` and `t2fanrd`. | install/hardware/apple/fix-t2.sh |
| OMA-14-031 | `apple/fix-t2.sh` | Apple T2 | Enable `t2fanrd`. Load `t2bce_vhci` and `hci_bcm4377`. | install/hardware/apple/fix-t2.sh |
| OMA-14-032 | `apple/fix-t2.sh` | Apple T2 | Add `t2bce_vhci usbhid hid_apple hid_generic xhci_pci xhci_hcd` to the initramfs. | install/hardware/apple/fix-t2.sh |
| OMA-14-033 | `apple/fix-t2.sh` | Apple T2 | Add `intel_iommu=on iommu=pt pm_async=off mem_sleep_default=deep` to the kernel command line. | install/hardware/apple/fix-t2.sh |
| OMA-14-034 | `apple/fix-t2.sh` | Apple T2 | Write `/etc/t2fand.conf` for Fan1 and Fan2 at 55/75. | install/hardware/apple/fix-t2.sh |
| OMA-14-035 | `apple/fix-brcmfmac-supplicant.sh` | Apple Broadcom Wi-Fi | Set `brcmfmac feature_disable=0x82000`. | install/hardware/apple/fix-brcmfmac-supplicant.sh |
| OMA-14-036 | `lenovo/fix-yoga-pro7-bass-speakers.sh` | Lenovo Yoga Pro 7 14IAH10 | Set `hda_model=alc287-yoga9-bass-spk-pin`. | install/hardware/lenovo/fix-yoga-pro7-bass-speakers.sh |
| OMA-14-037 | `fix-bcm43xx.sh` | Broadcom `14e4:43a0` or `14e4:4331` | Install `broadcom-wl-dkms`. | install/hardware/fix-bcm43xx.sh |
| OMA-14-038 | `fix-surface-keyboard.sh` | Microsoft Surface | Add the pinctrl and surface modules to the initramfs. | install/hardware/fix-surface-keyboard.sh |
| OMA-14-039 | `fix-yt6801-ethernet-adapter.sh` | Motorcomm YT6801 Ethernet | Install `yt6801-dkms`. | install/hardware/fix-yt6801-ethernet-adapter.sh |
| OMA-14-040 | `fix-tuxedo-backlight.sh` | TUXEDO or Slimbook | Install `tuxedo-drivers-nocompatcheck-dkms`. Blacklist `clevo_xsm_wmi`. | install/hardware/fix-tuxedo-backlight.sh |
| OMA-14-041 | `speaker-tuning.sh` | Machines that `omarchy-audio-tuning match` selects | Install `lsp-plugins-lv2`. The tuning for Dell XPS 2026 is `default/audio/tunings/dell-xps-2026`. | install/hardware/speaker-tuning.sh |
| OMA-14-042 | `pacman.sh` | Apple T2 | Add the `[arch-mact2]` repository. | install/hardware/pacman.sh |

| ID | Requirement | Source |
|---|---|---|
| OMA-14-043 | `install/hardware/all.sh` must run the quirks in the file order. The script detects the hardware itself. | install/hardware/all.sh |
| OMA-14-044 | The install path for `nvidia-dkms` is not determined. | install/omarchy-other.packages |

### User quirks (`install/user/hardware`)

| ID | Script | Hardware | Action | Source |
|---|---|---|---|---|
| OMA-14-045 | asus fix-audio-mixer | ASUS with ALC285 | Copy `alsa-soft-mixer.conf`. Set Master to 80%. | install/user/hardware/ |
| OMA-14-046 | asus fix-mic | ASUS | Set Internal Mic Boost to 0 and Capture to 70%. Run `alsactl store`. | install/user/hardware/ |
| OMA-14-047 | framework fix-f13-amd-audio-input | Framework 13 AMD | Set the PulseAudio profile `HiFi (Mic1, Mic2, Speaker)`. | install/user/hardware/ |
| OMA-14-048 | dell xps13-text-scaling | Dell XPS 13 (DX13260) | Run `omarchy-display-text-size 11`. | install/user/hardware/ |
| OMA-14-049 | fix-nouveau-cursor | nouveau driver without `nvidia.conf` | Add `cursor.no_hardware_cursors=true` to `looknfeel.lua`. | install/user/hardware/ |

### GPU

| ID | Requirement | Source |
|---|---|---|
| OMA-14-050 | Hybrid graphics must use `supergfxd` with a delayed start. | default/systemd/system/supergfxd.service.d/delay-start.conf |
| OMA-14-051 | `force-igpu` must be a system-sleep script on hardware that needs it. | default/systemd/system-sleep/force-igpu |

### Laptops

| ID | Requirement | Source |
|---|---|---|
| OMA-14-052 | The lid switch must run `omarchy-system-lid-close` on close and `omarchy-hyprland-monitor-clamshell` on open. | default/hypr/bindings/utilities.lua |
| OMA-14-053 | `omarchy-hw-*` commands must detect the laptop, battery, vendor and model (see section 11). | bin/omarchy-hw-* |
| OMA-14-054 | Keyboard backlight must have a system-sleep script on hardware that needs it. | default/systemd/system-sleep/keyboard-backlight |

### Fingerprint and FIDO2

| ID | Requirement | Source |
|---|---|---|
| OMA-14-055 | Fingerprint and FIDO2 setup must be in section 15. | bin/omarchy-setup-security-fingerprint; bin/omarchy-setup-security-fido2 |

## 15. Security

### Firewall

| ID | Requirement | Source |
|---|---|---|
| OMA-15-001 | `ufw` must deny incoming and allow outgoing traffic. | install/config/firewall.sh |
| OMA-15-002 | `ufw` must allow port 53317 on UDP and TCP for LocalSend. | install/config/firewall.sh |
| OMA-15-003 | `ufw` must allow DNS to `172.17.0.1` port 53 from `172.16.0.0/12` and `192.168.0.0/16` for Docker. | install/config/firewall.sh |
| OMA-15-004 | `ufw-docker` must be installed through a status shim. | install/config/firewall.sh |
| OMA-15-005 | `ufw` must have `ENABLED=yes` and must be enabled. | install/config/firewall.sh |

### SSH server

| ID | Requirement | Source |
|---|---|---|
| OMA-15-006 | `omarchy-setup-security-sshd` must run `ufw limit 22/tcp`. | bin/omarchy-setup-security-sshd |
| OMA-15-007 | After a key exists, it must write `/etc/ssh/sshd_config.d/10-omarchy-hardening.conf` with `PasswordAuthentication no` and `KbdInteractiveAuthentication no`. | bin/omarchy-setup-security-sshd |
| OMA-15-008 | It must check the config with `sshd -t`. | bin/omarchy-setup-security-sshd |

### Authentication

| ID | Requirement | Source |
|---|---|---|
| OMA-15-009 | `pam_faillock` must lock an account after 10 failures for 120 s. | install/config/increase-lockout-limit.sh |
| OMA-15-010 | `sudo` must allow 10 password tries. | etc/sudoers.d/ |
| OMA-15-011 | FIDO2 setup must install `libfido2` and `pam-u2f`. | bin/omarchy-setup-security-fido2 |
| OMA-15-012 | FIDO2 setup must add `auth sufficient pam_u2f.so cue authfile=/etc/fido2/fido2` to `sudo` and `polkit-1`. | bin/omarchy-setup-security-fido2 |
| OMA-15-013 | Fingerprint setup must add `pam_fprintd` to `sudo` and `polkit-1`. | bin/omarchy-setup-security-fingerprint |
| OMA-15-014 | A `pam_exec` call to `omarchy-hw-laptop-closed` must skip the fingerprint when the lid is closed. | bin/omarchy-setup-security-fingerprint |
| OMA-15-015 | Fingerprint setup must create `/etc/pam.d/omarchy-lock-fingerprint` and run `fprintd-enroll`. | bin/omarchy-setup-security-fingerprint |

### Sudo

| ID | Requirement | Source |
|---|---|---|
| OMA-15-016 | Passwordless sudo must use `/etc/sudoers.d/99-omarchy-nopasswd-$USER`. | bin/omarchy-sudo-passwordless |
| OMA-15-017 | A `systemd-run` timer must remove the passwordless file after 15 min by default. | bin/omarchy-sudo-passwordless |
| OMA-15-018 | tmpfiles must remove `/etc/sudoers.d/99-omarchy-nopasswd-*` at boot. | etc/tmpfiles.d/ |
| OMA-15-019 | The NOPASSWD rules must be limited to DNS switch, browser theme policy with a hex argument and timezone set. | etc/sudoers.d/ |

### Docker

| ID | Requirement | Source |
|---|---|---|
| OMA-15-020 | Sudoless Docker must be opt-in through `omarchy-setup-security-sudoless-docker`. The user is not in the `docker` group by default. | install/config/docker.sh; bin/omarchy-setup-security-sudoless-docker |
| OMA-15-021 | Membership of the `docker` group is equal to root access. | install/config/docker.sh |

### Disk and packages

| ID | Requirement | Source |
|---|---|---|
| OMA-15-022 | Disk encryption must be the default for ISO installs. | manual/02-getting-started.md |
| OMA-15-023 | pacman must require package signatures. | default/pacman/ |
| OMA-15-024 | `omarchy-drive-password` must change the LUKS password. | bin/omarchy-drive-password |

### Browser and keyring

| ID | Requirement | Source |
|---|---|---|
| OMA-15-025 | Chromium policy must be managed in `/etc/chromium/policies/managed`. | install/config/browser-policy.sh |
| OMA-15-026 | The default keyring must not lock on idle. | install/user/default-keyring.sh |
| OMA-15-027 | Password manager windows must not be shared on screen. | default/hypr/apps/ |

## 16. Testing and development tooling

### Tests

| ID | Requirement | Source |
|---|---|---|
| OMA-16-001 | `test/all` must run `test/cli` and `test/shell`. | test/all |
| OMA-16-002 | `test/shell` must run the 256 files `test/shell.d/*-test.sh`. | test/shell; test/shell.d/ |
| OMA-16-003 | `test/acceptance` must run the suites in `test/acceptance.d` in a VM through `omarchy-iso`. | test/acceptance |

| ID | Acceptance suite | Source |
|---|---|---|
| OMA-16-004 | `apps-test.sh` | test/acceptance.d/apps-test.sh |
| OMA-16-005 | `base-test.sh` | test/acceptance.d/base-test.sh |
| OMA-16-006 | `cups-test.sh` | test/acceptance.d/cups-test.sh |
| OMA-16-007 | `menu-test.sh` | test/acceptance.d/menu-test.sh |
| OMA-16-008 | `panels-test.sh` | test/acceptance.d/panels-test.sh |
| OMA-16-009 | `security-test.sh` | test/acceptance.d/security-test.sh |
| OMA-16-010 | `session-test.sh` | test/acceptance.d/session-test.sh |
| OMA-16-011 | `shell-surfaces-test.sh` | test/acceptance.d/shell-surfaces-test.sh |
| OMA-16-012 | `system-test.sh` | test/acceptance.d/system-test.sh |

### Development tools

| ID | Requirement | Source |
|---|---|---|
| OMA-16-013 | `omarchy-dev-link` must point `OMARCHY_PATH` at a git checkout. | bin/omarchy-dev-link |
| OMA-16-014 | The `dev` group commands must support development (see section 11). | bin/omarchy-dev-* |
| OMA-16-015 | The `omarchy.dev-gallery` panel must show the shell components. | shell/plugins/dev-gallery |
| OMA-16-016 | The style rules for contributors must be in `AGENTS.md`. | AGENTS.md |
| OMA-16-017 | The `.github` directory must contain only `ISSUE_TEMPLATE`. No CI workflow is in the repository. | .github/ |

### Agent skills

| ID | Skill | Source |
|---|---|---|
| OMA-16-018 | `acceptance-tests` | agents/skills/acceptance-tests.md |
| OMA-16-019 | `command-metadata` | agents/skills/command-metadata.md |
| OMA-16-020 | `icon-font` | agents/skills/icon-font.md |
| OMA-16-021 | `install-scripts` | agents/skills/install-scripts.md |
| OMA-16-022 | `shell-dev` | agents/skills/shell-dev.md |
| OMA-16-023 | `visual-verification` | agents/skills/visual-verification.md |

| ID | Requirement | Source |
|---|---|---|
| OMA-16-024 | The user skills `omarchy` and `diagnose-crash` must be in `default/agents/skills/`. | default/agents/skills/ |

