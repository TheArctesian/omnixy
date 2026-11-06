# Hardware support

Upstream Omarchy runs `install/hardware/*.sh` once, at install time. Each
script probes the machine (DMI strings, PCI/USB IDs, CPU model) and installs
packages or writes drop-ins for what it finds. OmniXY does the same job in
`modules/hardware.nix`, in two parts:

- **On by default** (`omnixy.hardware.quirks.enable`, default `true`). These
  quirks check the hardware themselves at runtime: udev rules matched on USB IDs,
  a systemd unit with `ConditionFirmware=smbios-field(...)`, modprobe `install`
  hooks that add a module option only after checking DMI/PCI IDs, and daemons with
  an `ExecCondition`. On other machines they do nothing, so every OmniXY system
  gets them, the same way upstream applies them wherever its detection matches.
- **Options** (`omnixy.hardware.<vendor>.*`). These need a decision when the
  system is built: a different kernel or driver, a daemon, or kernel parameters
  for one model. `omnixy-hardware-detect` prints the options that match the
  running machine:

```console
$ omnixy-hardware-detect
omnixy.hardware.nvidia.enable = true; # NVIDIA GPU with GSP firmware (Turing or newer): open kernel modules
omnixy.hardware.wirelessRegdom = "US"; # from timezone America/Los_Angeles

$ omnixy-hardware-detect --nix      # attrset for `omnixy.hardware = ...;` (the installer uses this)
{
  nvidia.enable = true; # NVIDIA GPU with GSP firmware (Turing or newer): open kernel modules
  wirelessRegdom = "US"; # from timezone America/Los_Angeles
}
```

The script only reads files and needs no root. Its output format is documented
at the top of `packages/omarchy/bin/omnixy-hardware-detect`.

## Options

| Option | What it does |
| --- | --- |
| `omnixy.hardware.quirks.enable` (default `true`) | The runtime-gated quirks listed below |
| `omnixy.hardware.asus.enable` | `services.asusd` (asusctl), so the keyboard lighting follows the theme; ALSA state persistence for the mic fix |
| `omnixy.hardware.asus.supergfxd.enable` | `services.supergfxd` (hybrid graphics switching) |
| `omnixy.hardware.asus.expertbookB9406.enable` | `xe.enable_panel_replay=0 xe.enable_dpcd_backlight=1` |
| `omnixy.hardware.asus.zenbookUX5406AA.enable` | `xe.enable_dpcd_backlight=1` |
| `omnixy.hardware.framework.enable` | `qmk_hid`, so the Framework 16 keyboard lighting follows the theme |
| `omnixy.hardware.nvidia.enable` | Proprietary driver with open kernel modules, modesetting, early KMS |
| `omnixy.hardware.nvidia.legacy` | 580 legacy branch with closed modules (Maxwell, Pascal, Volta) |
| `omnixy.hardware.apple.t2.enable` | T2 kernel parameters (`intel_iommu=on iommu=pt pm_async=off mem_sleep_default=deep`) and `hci_bcm4377`. You still need to import `nixos-hardware.nixosModules.apple-t2` for the kernel. The module warns if it is missing |
| `omnixy.hardware.apple.spiKeyboard.enable` | `applespi` and the LPSS/SPI drivers in the initrd |
| `omnixy.hardware.surface.enable` | Surface Aggregator/keyboard drivers and Intel pinctrl in the initrd |
| `omnixy.hardware.broadcom.wl.enable` | Broadcom `wl` (broadcom_sta). nixpkgs marks it insecure, and setting this option accepts that |
| `omnixy.hardware.intel.pantherLake.enable` | `fred=on` |
| `omnixy.hardware.intel.ipu7` (`"ipu7x"` / `"ipu75xa"`) | `hardware.ipu7` (MIPI camera) |
| `omnixy.hardware.dell.xpsHapticTouchpad.enable` | The omarchy-pkgs haptics daemon and the `dell-xps-touchpad-haptics` CLI that the menu calls |
| `omnixy.hardware.tuxedo.enable` | `hardware.tuxedo-drivers`, with `clevo_xsm_wmi` blacklisted |
| `omnixy.hardware.motorcomm.yt6801.enable` | Out-of-tree Motorcomm YT6801 Ethernet driver |
| `omnixy.hardware.wirelessRegdom` (`"GB"`) | `cfg80211 ieee80211_regdom=` |

nixos-hardware profiles still help on top of these, for example
`framework-16-7040-amd`, `apple-t2` and `microsoft-surface-common`.
`omnixy-hardware-detect` suggests them as comments.

## Upstream scripts

### `install/hardware`

| Upstream script | OmniXY | Notes |
| --- | --- | --- |
| `asus-rog.sh` | option `asus.enable` | asusctl comes from `services.asusd` |
| `asus/fix-asus-ptl-b9406-display.sh` | option `asus.expertbookB9406.enable` | Kernel parameter |
| `asus/fix-asus-ptl-display-backlight.sh` | options `asus.expertbookB9406.enable`, `asus.zenbookUX5406AA.enable` | Kernel parameter |
| `asus/fix-asus-ptl-b9406-touchpad.sh` | on by default | `/etc/libinput/local-overrides.quirks`, matched on DMI and the touchpad ID. libinput reads only that file from `/etc`, so upstream's `asus-expertbook-b9406.quirks` name would be ignored |
| `asus/fix-z13-touchpad.sh` | on by default | udev rule on USB `0b05:1a30` |
| `framework16.sh` | option `framework.enable` | `qmk_hid` |
| `framework/qmk-hid.sh` | on by default | udev rule on USB `32ac:0012` (upstream's rules file) |
| `dell-xps-touchpad-haptics.sh` | option `dell.xpsHapticTouchpad.enable` | omarchy-pkgs `dell-xps-touchpad-haptics`, packaged in `packages/dell-xps-touchpad-haptics.nix` |
| `dell-xps13-ptl-speaker-firmware.sh` | on by default | nixpkgs' linux-firmware (20261019) already has the `10280e54` Cirrus aliases that the omarchy-pkgs package adds. Redistributable firmware is on |
| `surface.sh` | on by default | `linux-firmware-marvell` is part of linux-firmware |
| `fix-surface-keyboard.sh` | option `surface.enable` | initrd modules. udev picks the matching pinctrl driver |
| `apple/fix-t2.sh` | option `apple.t2.enable` + nixos-hardware `apple-t2` | linux-t2, audio config and Wi-Fi firmware come from nixos-hardware. `t2fanrd` is not in nixpkgs (not ported). The T2 kernel's applesmc fan support is used |
| `apple/fix-brcmfmac-supplicant.sh` | on by default | modprobe `install` hook adds `feature_disable=0x82000` only when the DMI vendor is Apple |
| `apple/fix-spi-keyboard.sh` | option `apple.spiKeyboard.enable` | `applespi` is in mainline, so no DKMS driver is needed |
| `apple/fix-suspend-nvme.sh` | on by default | `omnixy-apple-nvme-suspend.service`, gated with `ConditionFirmware=smbios-field(product_name ...)` |
| `fix-bcm43xx.sh` | option `broadcom.wl.enable` | |
| `fix-fkeys.sh` | on by default | `options hid_apple fnmode=2`, applied everywhere as upstream does |
| `intel/fix-wifi7-eht.sh` | on by default | modprobe hook adds `disable_11be=Y` only with a BE200/BE211 (`8086:e440`/`272b`) |
| `lenovo/fix-yoga-pro7-bass-speakers.sh` | on by default | modprobe hook adds `hda_model=...` only when the DMI name/family matches `Yoga Pro 7 14IAH10` |
| `intel/thermald.sh` | on by default (x86_64) | thermald is installed; `ExecCondition` starts it only on Intel model ≥ 42 with a battery |
| `intel/lpmd.sh` | on by default (x86_64) | intel-lpmd is installed; `ExecCondition` uses upstream's CPU model list and battery check |
| `intel/video-acceleration.sh` | on by default (x86_64) | `intel-media-driver`, `intel-vaapi-driver`, `vpl-gpu-rt` in `hardware.graphics.extraPackages`. libva picks by PCI ID |
| `intel/sof-firmware.sh` | on by default | `sof-firmware` is part of redistributable firmware |
| `intel/ipu7-camera.sh` | option `intel.ipu7` | `hardware.ipu7` needs the platform, which the detect script reads from the IPU PCI ID |
| `intel/fred.sh` | option `intel.pantherLake.enable` | Kernel parameter |
| `nvidia.sh` | options `nvidia.enable`, `nvidia.legacy` | `hardware.nvidia`. Hybrid laptops also need `hardware.nvidia.prime` bus IDs |
| `vulkan.sh` | not needed | Mesa on NixOS ships every Vulkan driver (ANV, RADV, Asahi). NVIDIA's comes with the driver |
| `fix-tuxedo-backlight.sh` | option `tuxedo.enable` | No orphaned `.ko` files to clean up on NixOS |
| `fix-yt6801-ethernet-adapter.sh` | option `motorcomm.yt6801.enable` | |
| `speaker-tuning.sh` | on by default | The base packages ship lsp-plugins' LV2 bundle (the limiter the tunings use) and `LV2_PATH`; the package also rewrites the script's `/usr/lib/lv2` check and the tuning unit's `/usr/bin/pipewire` |
| `set-wireless-regdom.sh` | option `wirelessRegdom` | Upstream reads the timezone at install time. The detect script does the same |
| `fix-synaptic-touchpad.sh` | not applicable | Upstream only runs `modprobe psmouse synaptics_intertouch=1` on the live system and does not persist it (see the script's comment). Nothing carries over to the installed system |
| `bluetooth.sh` | `omnixy.features.bluetooth` | `modules/services.nix` |
| `network.sh` | not applicable | Retires archinstall's systemd-networkd files. NixOS never enables networkd alongside NetworkManager here |
| `pacman.sh` | not applicable | Adds the arch-mact2 pacman repo. On NixOS, nixos-hardware provides the T2 kernel |

### `install/user/hardware` (first login)

These still run from `omarchy-provision-first-run` as upstream. They work on
OmniXY because the tools they call are in the system path.

| Upstream script | OmniXY |
| --- | --- |
| `asus/fix-audio-mixer.sh` | Works (WirePlumber soft mixer drop-in, `amixer`) |
| `asus/fix-mic.sh` | Works. `sudo alsactl store` only succeeds interactively, but `asus.enable` turns on ALSA persistence, which saves the levels at shutdown |
| `framework/fix-f13-amd-audio-input.sh` | Works (`pactl` is in the system path) |
| `dell/xps13-text-scaling.sh` | Works |
| `fix-nouveau-cursor.sh` | Works. It checks `lspci -k` for nouveau. With `nvidia.enable`, nouveau is blacklisted, so it does not fire |

### Detection helpers (`bin/omarchy-hw-*`)

The helpers are unchanged. They read sysfs and call `lspci`, and both work on
NixOS. `omnixy-hardware-detect` re-implements the subset that install time
needs, reading only sysfs, so that it can run against a fixture tree
(`OMNIXY_HW_ROOT`).

### Keyboard lighting

`omarchy-theme-set-keyboard-asus-rog` needs `asusctl` and a running `asusd`
(`asus.enable`). `omarchy-theme-set-keyboard-f16` needs `qmk_hid`
(`framework.enable`) and the uaccess udev rule, which is on by default.

## Not ported

- **t2fanrd** (T2 fan curve daemon) is not packaged in nixpkgs.
- **Initrd firmware for the XPS 13 DX13260 speakers.** Upstream puts it in the
  initrd for encrypted roots. NixOS loads sound drivers after the root is
  mounted, so it is not needed.
