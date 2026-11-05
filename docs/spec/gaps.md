# Gap analysis: Omarchy v4.0.6 vs OmniXY

This compares [omarchy-spec.md](omarchy-spec.md) (`OMA-*`, upstream behaviour) with [omnixy-spec.md](omnixy-spec.md) (`ONX-*`, OmniXY as re-audited after PRs #3 and #4). Both specs are in ASD-STE100 Simplified Technical English and use the same 16-section outline. `ONX-*` statuses were re-audited on 2026-11-04, after PRs #3 and #4. They describe the tree *after* the fixes below.

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
| Dead `faillock.conf` with no `pam_faillock` (ONX-15-004) | Removed (see open gaps) |

## Open gaps

| Gap | Why it is still open |
| --- | --- |
| tobi-try, asdcontrol, voxtype install path, NordVPN, ONCE, ChatGPT/Codex desktop, T3 Code, Hermes, OpenClaw, Perplexity, Grok, Zen, omarchy-emacs (ONX-5-016, ONX-11-021…025, ONX-9-035) | Not in nixpkgs. They report "Not packaged for NixOS". |
| Lutris | nixpkgs marks a dependency (gtk2) insecure. Installing needs `nixpkgs.config.permittedInsecurePackages`. The `sudo sed /usr/bin/lutris` step still fails. |
| `pam_faillock` (OMA-6-048, OMA-8-056) | NixOS has no faillock option. Wiring it through `security.pam.services.*.rules` affects every login path and needs real-hardware testing first. NixOS has *no* lockout by default, so this is a hardening gap, not a usability one. |
| Hardware quirks (`install/hardware/*`, ONX-14-003), `asusctl`, `qmk_hid` keyboard lights (ONX-10-007, ONX-11-049) | Machine-specific. Use nixos-hardware and `services.asusd`. They are not on by default. |
| `omarchy-install-dev-env` PHP edits `/etc/php`; prebuilt mise runtimes need nix-ld (ONX-11-030) | Needs a design decision: enabling `programs.nix-ld` system-wide changes what binaries run. |
| `omarchy-debug` / `omarchy-upload-log` package section uses pacman (ONX-11-095/096) | It degrades to "unknown"; cosmetic. |
| GeForce NOW (flatpak), Steam, Tailscale, sshd, fprintd, FIDO2 | Option-backed by design: the command prints the option and stops. |
| `omarchy-update-available` often reports updates (ONX-8-010) | nixos-unstable moves daily. A stable channel or a less frequent check would fix it. |
| SDDM runs on Weston, not Hyprland (ONX-10-011) | NixOS' SDDM Wayland mode. The visual result is the same theme. |
| Guided installer (ONX-4-009) | The ISO is a live desktop with `nixos-install`/disko. |
