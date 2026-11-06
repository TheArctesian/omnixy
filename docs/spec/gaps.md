# Gap analysis: Omarchy v4.0.6 vs OmniXY

This compares [omarchy-spec.md](omarchy-spec.md) (`OMA-*`, upstream behaviour) with [omnixy-spec.md](omnixy-spec.md) (`ONX-*`, OmniXY as re-audited after PRs #3 and #4). Both specs are in ASD-STE100 Simplified Technical English and use the same 16-section outline. `ONX-*` statuses were re-audited on 2026-11-04, after PRs #3 and #4. They describe the tree *after* the fixes below. PR #5 then fixed every row that was still `BROKEN` (see the second table).

## Fixed in this change

| Gap (spec IDs) | Fix |
| --- | --- |
| Second theme switch leaves an incomplete theme (ONX-10-004, ONX-11-046, ONX-9-022) | `omnixy-cp`: scripts' `cp` calls make store copies writable. Covered by the VM test. |
| `[[ -x /usr/bin/foo ]]` became a relative test, so Signal and Spotify always re-run their installer (ONX-9-010/013, ONX-11-075, ONX-12-010) | Rewritten to `command -v foo` |
| `/usr/bin/…` left in scripts: Cursor theme, browser hand-off, windows-vm, reload guard (ONX-3-009, ONX-10-006, ONX-11-124/129) | Generic `/usr/bin/x` → `x`; browser hand-off matches by name |
| `PACKAGED_PATH=/usr/bin/…` sudo re-exec in DNS and browser policy (ONX-10-005, ONX-11-047/127) | Points at `/run/current-system/sw/bin`, with sudoers grants that match upstream |
| Upstream sudoers.d not mirrored; no `@includedir`; NOPASSWD cleanup missing (ONX-15-003/013, ONX-11-123) | `modules/tuning.nix`: `passwd_tries=10`, DNS/browser/timezone grants, `@includedir /etc/sudoers.d`, `r!` tmpfiles cleanup |
| `pactl` absent: volume keys, output switch, audio tuning (ONX-4-018, ONX-5-008, ONX-9-037/039, ONX-11-098…102) | `pactl` only (no PulseAudio daemon); PipeWire serves it |
| `gtk-launch`, `gtk-update-icon-cache`, `iw`, `v4l2-ctl`, `cryptsetup`, `efibootmgr` absent (ONX-5-010/011, ONX-11-029/033/106/110/111/114/115/126, ONX-9-028) | Added to the base packages |
| Bundled web app / TUI icons missing (ONX-3-011, ONX-7-008, ONX-12-006) | Installed into `hicolor/256x256/apps` under upstream's names |
| `localsend` binary name (ONX-5-018, ONX-9-030, ONX-11-080, ONX-12-005) | `localsend` → `localsend_app` link |
| No fcitx5 GTK/Qt modules (ONX-5-009, ONX-7-015) | `i18n.inputMethod` fcitx5 + fcitx5-gtk, Wayland frontend |
| Hyprland ignores the keyboard layout (ONX-6-028) | `/etc/vconsole.conf` gets `XKBLAYOUT`/`XKBVARIANT`/`XKBOPTIONS` from `services.xserver.xkb` |
| `time.timeZone` pinned, so the timezone menu fails (ONX-6-029, ONX-11-081) | Example host and template leave it unset |
| resolved LLMNR/mDNS/Docker stub, NM Wi-Fi powersave, oomd limits, logind power key + inhibit delay, manager timeouts and NOFILE, sysctl, usbcore autosuspend, zswap off, plocate on AC, `user@` stop timeout (ONX-6-004/005/013/015/017–021, ONX-9-019) | `modules/tuning.nix` |
| Docker `daemon.json`, user not in `docker` (ONX-6-010/011) | `virtualisation.docker.daemon.settings`; `docker` group |
| thermald off (ONX-14-006) | On for Intel machines (`hardware.cpu.intel.updateMicrocode`) |
| dirmngr, kitty, fastfetch, mise `/etc` files (ONX-6-033) | `environment.etc` from the packaged `etc/` |
| `omnixy-pkg present` for option-backed packages never succeeds (ONX-11-040, ONX-14-009, ONX-9-016) | Per-package probes (`op`, `sshd`, `fprintd-list`, `pam_u2f` in PAM, …) |
| AUR installs (Chrome, Edge, Brave) call the stub (ONX-11-013) | `omarchy-pkg-aur-add` → `omarchy-pkg-add` (nixpkgs mapping) |
| Nerd font, Zed, Kdenlive, Xdebug, RetroArch core names (ONX-11-012/015/016/017) | Mapped to nixpkgs attributes (all verified to evaluate); RetroArch cores come from `retroarch-full`, config paths point at the nix profile |
| 1Password writes `/usr/share/chromium/extensions` (ONX-11-019) | Override prints the NixOS options, including `programs.chromium.extensions` |
| `omarchy-reinstall-configs` / `omarchy-reinstall` stop on stubs (ONX-11-086/087) | Reimplemented on `omnixy-seed-user --force` |
| Plymouth / SDDM refresh and Style › Unlock need `limine-mkinitcpio` (ONX-10-012, ONX-11-089/141) | Refresh commands are no-ops (declarative); `plymouth-set*` print the option; Style › Unlock removed |
| `omarchy-plymouth-current` reads `/usr/share/plymouth` (ONX-11-109) | Path rewritten; theme in the system profile |
| `omarchy-hw-vulkan` path (ONX-11-065) | `/run/opengl-driver/share/vulkan/icd.d` |
| fido2/fingerprint remove edit read-only `/etc/pam.d` (ONX-11-034, ONX-15-010) | Print the option to remove |
| `omarchy-remove-dev-env` calls pacman (ONX-11-035) | `omarchy-pkg-drop` |
| Firmware update stubbed | `omarchy-update-firmware` runs `fwupdmgr` (fwupd is on); menu entry restored |
| Reset Computer calls the factory-reset stub (ONX-11-082) | Menu entry removed |
| Sunshine firewall (ONX-11-020) | Printed option includes `openFirewall`; the script already skips ufw when it is absent |
| Omarchy's own apps: omacalc, omacut, omawrite, aether, omazed, omarchy-nvim (ONX-5-014/015, ONX-9-015/021, ONX-12-007/008) | Built from source in `packages/` (follow-up change). `omnixy-pkg` installs them from the registered `omnixy` flake. omarchy-nvim is seeded on login without the prebuilt plugin cache. |
| Root halves of `omarchy-dns`, `omarchy-theme-set-browser-policy`, `omarchy-windows-vm` pin `PATH` to empty FHS dirs (ONX-11-127, ONX-10-005, ONX-11-047, ONX-11-124; found by the re-audit) | `PATH` is the system profile. The VM test runs `sudo -n omarchy-dns DHCP` for real. |
| `omarchy-audio-tuning` needs lsp-plugins at `/usr/lib/lv2` (ONX-11-102, ONX-4-018) | The LV2 bundle (without its UI library) is in the base packages; path rewritten; `LV2_PATH` set for the session |
| `omarchy-debug` / `omarchy-upload-log` package section uses pacman (ONX-11-095/096) | `omnixy-pkg list` (system and profile packages) |
| Omarchy user units get NixOS's minimal `PATH`, so the sleep lock fails (`dbus-monitor: not found`) | System and per-user profiles on their `path` |
| Dead `faillock.conf` with no `pam_faillock` (ONX-15-004) | Removed, then replaced by real `pam_faillock` rules (PR #5, below) |

## Fixed in PR #5

| Gap (spec IDs) | Fix |
| --- | --- |
| Guided installer (ONX-4-009) | `omnixy-install`: gum TUI, disko (ESP + btrfs, optional LUKS2), generated flake with detected `omnixy.hardware`, `nixos-install`; autostarts on the ISO. Plain and LUKS installs tested end-to-end in QEMU. Also fixed: SDDM login on a fresh install (no last user), live session locking mid-install |
| `pam_faillock` (ONX-15-004) | `deny=10 unlock_time=120` rules around `pam_unix` in login, sudo, su, polkit-1, sshd and the lock screen; VM-tested |
| tobi-try, asdcontrol (ONX-5-016) | Packaged and in the base set; upstream's asdcontrol sudoers grant |
| NordVPN, ONCE (ONX-11-021/022) | `omnixy.features.nordvpn`, `omnixy.features.once` |
| ChatGPT/Codex, T3 Code (ONX-11-023/024) | nixpkgs `chatgpt`, `t3code` |
| Perplexity, Grok Bot, Zen, OpenClaw, Hermes (ONX-11-025) | Built from upstream's packages (OpenClaw as its self-updating seed); Hermes from the hermes-agent flake |
| omarchy-emacs (ONX-11-014) | Packaged; `emacs.service` linked from the profile |
| Lutris (ONX-11-018) | Exported from the OmniXY flake with gtk2's deprecation flag set to warn; shebang rewrite dropped; lib32 drivers map to `hardware.graphics.enable32Bit` |
| voxtype unit (ONX-9-035, ONX-11-119) | The generated unit runs the profile's `voxtype`, not a store path |
| Firefox / Zen policies | Written to `/etc/<app>/policies`, which nixpkgs' builds read |
| `omarchy-setup-direct-boot` (ONX-11-110) | Prints `boot.loader.timeout = 0;` (no UKI on NixOS; the menu stays available for rollback) |
| Hardware quirks, ASUS/Framework keyboard lights (ONX-4-029, ONX-14-003/006/008, ONX-10-007) | `modules/hardware.nix`, `omnixy-hardware-detect`; see [../hardware.md](../hardware.md) |

## Open gaps

| Gap | Why it is still open |
| --- | --- |
| Hardware quirks are untested on the real machines | Each quirk checks the hardware or is an option; evals pass, but nobody has run them on an ASUS, Framework, Mac or Surface yet. linux-t2 / linux-surface kernels come from nixos-hardware; t2fanrd is not packaged. |
| `omarchy-install-dev-env` PHP edits `/etc/php`; prebuilt mise runtimes need nix-ld (ONX-11-030) | Needs a design decision: enabling `programs.nix-ld` system-wide changes what binaries run. |
| GeForce NOW (flatpak), Steam, Tailscale, sshd, fprintd, FIDO2, NordVPN, ONCE | Option-backed by design: the command prints the option and stops. |
| `omarchy-update-available` often reports updates (ONX-8-010) | nixos-unstable moves daily. A stable channel or a less frequent check would fix it. |
| SDDM runs on Weston, not Hyprland (ONX-10-011) | NixOS' SDDM Wayland mode. The visual result is the same theme. |
| `etc/profile.d/omarchy.sh` (ONX-6-033) | Not mirrored. It sources `env-bootstrap`, which the OmniXY session already does. Check that login shells outside the session do not need it. |
| Hermes and OpenClaw onboarding | Need API keys; the install and remove paths were tested in a scratch home only. Hermes updates with the flake input, not `hermes update`. |
