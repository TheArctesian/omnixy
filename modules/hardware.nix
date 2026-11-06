# install/hardware/*.sh, declaratively. docs/hardware.md maps every upstream
# script to what happens here.
#
# Upstream probes the machine once at install time and writes drop-ins for
# what it finds. OmniXY splits that in two:
#
#  - Quirks that gate themselves at runtime (udev rules matched on USB/DMI IDs,
#    units with ConditionFirmware, modprobe hooks that check DMI/PCI IDs before
#    adding an option, daemons with an ExecCondition) are on for every machine
#    under omnixy.hardware.quirks.enable, the default. On other hardware they do
#    nothing.
#  - Quirks that need a decision at build time (a kernel, a driver, a daemon,
#    kernel parameters for one model) are options under omnixy.hardware.*.
#    `omnixy-hardware-detect` prints the ones that match the running machine.
{
  config,
  lib,
  options,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkIf
    mkMerge
    mkOption
    mkDefault
    optional
    optionals
    types
    ;
  cfg = config.omnixy;
  hw = cfg.hardware;
  x86 = pkgs.stdenv.hostPlatform.isx86_64;

  # Exits 0 when the named quirk applies to this machine. Pure bash builtins:
  # modprobe runs it from udev with an unknown PATH.
  hwCheck = pkgs.writeShellScript "omnixy-hw-check" ''
    dmi=/sys/class/dmi/id

    read_file() { [[ -r $1 ]] && printf '%s' "$(<"$1")"; }

    dmi_match() {
      local want=''${1,,} name family
      name=$(read_file $dmi/product_name)
      family=$(read_file $dmi/product_family)
      [[ ''${name,,} == *"$want"* || ''${family,,} == *"$want"* ]]
    }

    pci_has() {
      local dev
      for dev in /sys/bus/pci/devices/*; do
        [[ $(read_file "$dev/vendor") == "$1" && $(read_file "$dev/device") =~ $2 ]] && return 0
      done
      return 1
    }

    cpu_field() {
      local key value
      while IFS=: read -r key value; do
        key=''${key%"''${key##*[![:space:]]}"}
        if [[ $key == "$1" ]]; then
          printf '%s' "''${value// /}"
          return 0
        fi
      done </proc/cpuinfo
      return 1
    }

    battery_present() {
      local bat
      for bat in /sys/class/power_supply/BAT*; do
        [[ $(read_file "$bat/present") == 1 && $(read_file "$bat/type") == Battery ]] && return 0
      done
      return 1
    }

    intel_model() {
      [[ $(cpu_field vendor_id) == GenuineIntel ]] || return 1
      cpu_field model
    }

    case ''${1:-} in
    # apple/fix-brcmfmac-supplicant.sh. brcmfmac drives every Mac Wi-Fi part
    # except the BCM4360/4331, which use wl and never read this option.
    apple) [[ $(read_file $dmi/sys_vendor) == Apple* ]] ;;
    # intel/fix-wifi7-eht.sh: Intel BE200/BE211.
    intel-be200) pci_has 0x8086 '^0x(e440|272b)$' ;;
    # lenovo/fix-yoga-pro7-bass-speakers.sh
    yoga-pro7-14iah10) dmi_match "Yoga Pro 7 14IAH10" ;;
    # intel/thermald.sh: Sandy Bridge (model 42) or newer, on battery hardware.
    thermald)
      model=$(intel_model) || exit 1
      [[ $model =~ ^[0-9]+$ ]] && ((model >= 42)) && battery_present
      ;;
    # intel/lpmd.sh: hybrid Intel laptops, Alder Lake and newer.
    intel-lpmd)
      model=$(intel_model) || exit 1
      [[ " 151 154 170 172 183 186 189 191 204 " == *" $model "* ]] && battery_present
      ;;
    *) exit 1 ;;
    esac
  '';

  # modprobe `install` hook: load the module with extra options only when
  # hwCheck says the quirk applies.
  #   install <mod> modprobeQuirk <check> <mod> <option>... -- $CMDLINE_OPTS
  modprobeQuirk = pkgs.writeShellScript "omnixy-modprobe-quirk" ''
    check=$1 module=$2
    shift 2
    extra=()
    while (($#)) && [[ $1 != -- ]]; do
      extra+=("$1")
      shift
    done
    (($#)) && shift
    if ${hwCheck} "$check"; then
      set -- "''${extra[@]}" "$@"
    fi
    exec ${pkgs.kmod}/bin/modprobe --ignore-install "$module" "$@"
  '';
  gatedOptions =
    module: check: opts:
    "install ${module} ${modprobeQuirk} ${check} ${module} ${lib.concatStringsSep " " opts} -- $CMDLINE_OPTS";

  # apple/fix-suspend-nvme.sh models.
  nvmeSuspendMacs = [
    "MacBook[89],1"
    "MacBook10,1"
    "MacBookPro1[34],[123]"
  ];

  haptics = pkgs.callPackage ../packages/dell-xps-touchpad-haptics.nix { };
in
{
  options.omnixy.hardware = {
    quirks.enable = mkEnableOption "" // {
      default = true;
      description = ''
        Apply upstream's hardware quirks that gate themselves at runtime: they
        match on DMI, PCI or USB IDs and do nothing on other machines (Apple
        Wi-Fi handshake and NVMe suspend, Apple-style F-keys, Intel BE200 Wi-Fi 7,
        Lenovo Yoga Pro 7 bass speakers, ASUS ExpertBook B9406 and ROG Flow Z13
        touchpads, Framework 16 keyboard access, thermald and intel-lpmd on
        supported Intel laptops, Intel VA-API drivers, redistributable firmware).
        See docs/hardware.md.
      '';
    };

    asus = {
      enable = mkEnableOption "ASUS ROG support: asusd and asusctl (keyboard lighting follows the theme), ALSA state persistence for the mic fix";
      supergfxd.enable = mkEnableOption "supergfxd, ASUS hybrid-graphics switching";
      expertbookB9406.enable = mkEnableOption "the ASUS ExpertBook B9406 (Panther Lake) display fixes: xe.enable_panel_replay=0 and xe.enable_dpcd_backlight=1";
      zenbookUX5406AA.enable = mkEnableOption "the ASUS Zenbook UX5406AA (Panther Lake) backlight fix: xe.enable_dpcd_backlight=1";
    };

    framework.enable = mkEnableOption "Framework Laptop 16 support: qmk_hid, so the keyboard lighting follows the theme";

    nvidia = {
      enable = mkEnableOption "the proprietary NVIDIA driver with early KMS (open kernel modules unless `legacy` is set)";
      legacy = mkEnableOption "the 580 legacy branch with closed modules, for Maxwell, Pascal and Volta GPUs (no GSP firmware)";
    };

    apple = {
      t2.enable = mkEnableOption ''
        T2 Mac kernel parameters and Bluetooth module. The T2 kernel, audio
        config and Wi-Fi firmware come from nixos-hardware: import
        `nixos-hardware.nixosModules.apple-t2` as well'';
      spiKeyboard.enable = mkEnableOption "the SPI keyboard drivers in the initrd (MacBook 8,1-10,1, MacBookPro 13,x-14,x), so the disk password can be typed";
    };

    surface.enable = mkEnableOption "the Surface keyboard drivers in the initrd, so the disk password can be typed. For the linux-surface kernel use nixos-hardware's microsoft-surface modules";

    broadcom.wl.enable = mkEnableOption "Broadcom's proprietary `wl` driver for BCM4360/BCM4331 Wi-Fi. nixpkgs marks it insecure; enabling this option accepts that";

    intel = {
      pantherLake.enable = mkEnableOption "FRED (fred=on) on Intel Panther Lake";
      ipu7 = mkOption {
        type = types.nullOr (
          types.enum [
            "ipu7x"
            "ipu75xa"
          ]
        );
        default = null;
        example = "ipu75xa";
        description = "Enable the Intel IPU7 MIPI camera stack (hardware.ipu7) for this platform: ipu7x is Lunar Lake, ipu75xa is Panther Lake.";
      };
    };

    dell.xpsHapticTouchpad.enable = mkEnableOption "the Dell XPS haptic touchpad daemon (Omarchy menu: Trigger > Hardware > Touchpad haptics)";

    tuxedo.enable = mkEnableOption "tuxedo-drivers for TUXEDO and Slimbook (Clevo) keyboard backlights";

    motorcomm.yt6801.enable = mkEnableOption "the out-of-tree Motorcomm YT6801 Ethernet driver (Slimbook Executive)";

    wirelessRegdom = mkOption {
      type = types.nullOr (types.strMatching "[A-Z]{2}");
      default = null;
      example = "GB";
      description = ''
        Wireless regulatory domain (ISO 3166 country code). Upstream derives it
        from the timezone at install time (set-wireless-regdom.sh);
        `omnixy-hardware-detect` does the same.
      '';
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf hw.quirks.enable {
      # intel/sof-firmware.sh, surface.sh (Marvell Wi-Fi),
      # dell-xps13-ptl-speaker-firmware.sh (the Cirrus aliases are in
      # linux-firmware since 20261019), apple T2 Bluetooth.
      hardware.enableRedistributableFirmware = mkDefault true;

      # fix-fkeys.sh: Apple-style keyboards (Lofree Flow84...) send F-keys.
      boot.extraModprobeConfig = "options hid_apple fnmode=2";

      # Not in nixos.conf: that file is copied into the initrd, where the
      # hook's store path does not exist.
      environment.etc."modprobe.d/omnixy-hardware.conf".text = ''
        # apple/fix-brcmfmac-supplicant.sh
        ${gatedOptions "brcmfmac" "apple" [ "feature_disable=0x82000" ]}
        # intel/fix-wifi7-eht.sh
        ${gatedOptions "iwlwifi" "intel-be200" [ "disable_11be=Y" ]}
        # lenovo/fix-yoga-pro7-bass-speakers.sh
        ${gatedOptions "snd_sof_intel_hda_generic" "yoga-pro7-14iah10" [
          "hda_model=alc287-yoga9-bass-spk-pin"
        ]}
      '';

      # apple/fix-suspend-nvme.sh
      systemd.services.omnixy-apple-nvme-suspend = {
        description = "Keep the MacBook NVMe out of D3cold so it wakes from suspend";
        wantedBy = [ "multi-user.target" ];
        unitConfig = {
          ConditionFirmware = map (m: ''|smbios-field(product_name $= "${m}")'') nvmeSuspendMacs;
          ConditionPathExists = "/sys/bus/pci/devices/0000:01:00.0/d3cold_allowed";
        };
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = pkgs.writeShellScript "omnixy-apple-nvme-suspend" ''
            echo 0 > /sys/bus/pci/devices/0000:01:00.0/d3cold_allowed
          '';
        };
      };

      services.udev.extraRules = ''
        # asus/fix-z13-touchpad.sh: the ROG Flow Z13 detachable keyboard's
        # touchpad counts as internal, so disable-while-typing pairs with it.
        ACTION=="add|change", KERNEL=="event*", ATTRS{idVendor}=="0b05", ATTRS{idProduct}=="1a30", ENV{ID_INPUT_TOUCHPAD}=="1", ENV{ID_INPUT_TOUCHPAD_INTEGRATION}="internal"
        # framework/qmk-hid.sh: user access to the Framework 16 keyboard (RGB).
        ${builtins.readFile "${pkgs.omarchy.upstreamSrc}/default/udev/framework16-qmk-hid.rules"}
      '';

      # asus/fix-asus-ptl-b9406-touchpad.sh. libinput only reads this one file
      # from /etc (upstream's asus-expertbook-b9406.quirks name is never read).
      environment.etc."libinput/local-overrides.quirks".text = mkDefault ''
        [ASUS ExpertBook B9406 Touchpad]
        MatchBus=i2c
        MatchUdevType=touchpad
        MatchVendor=0x093A
        MatchProduct=0x4F05
        MatchDMIModalias=dmi:*svnASUS*:pn*B9406*
        AttrEventCode=-ABS_MT_PRESSURE;-ABS_PRESSURE;
      '';
    })

    (mkIf (hw.quirks.enable && x86) {
      # intel/thermald.sh, intel/lpmd.sh: installed everywhere, started only
      # where upstream would have installed them.
      services.thermald.enable = mkDefault true;
      systemd.services.thermald.serviceConfig.ExecCondition = mkDefault "${hwCheck} thermald";
      services.intel-lpmd.enable = mkDefault true;
      systemd.services.intel_lpmd.serviceConfig.ExecCondition = mkDefault "${hwCheck} intel-lpmd";

      # intel/video-acceleration.sh. libva picks the driver by PCI ID, so
      # these are inert on AMD/NVIDIA. Vulkan (vulkan.sh) is Mesa's default.
      hardware.graphics.extraPackages = with pkgs; [
        intel-media-driver
        intel-vaapi-driver
        vpl-gpu-rt
      ];
    })

    (mkIf hw.asus.enable {
      # asus-rog.sh; omarchy-theme-set-keyboard-asus-rog needs asusctl + asusd.
      services.asusd.enable = true;
      # user/hardware/asus/fix-mic.sh stores the mic levels with alsactl.
      hardware.alsa.enablePersistence = mkDefault true;
    })
    (mkIf hw.asus.supergfxd.enable { services.supergfxd.enable = true; })
    (mkIf hw.asus.expertbookB9406.enable {
      # asus/fix-asus-ptl-b9406-display.sh, fix-asus-ptl-display-backlight.sh
      boot.kernelParams = [
        "xe.enable_panel_replay=0"
        "xe.enable_dpcd_backlight=1"
      ];
    })
    (mkIf hw.asus.zenbookUX5406AA.enable {
      # asus/fix-asus-ptl-display-backlight.sh
      boot.kernelParams = [ "xe.enable_dpcd_backlight=1" ];
    })

    (mkIf hw.framework.enable {
      # framework16.sh; omarchy-theme-set-keyboard-f16 drives it.
      environment.systemPackages = [ pkgs.qmk_hid ];
    })

    (mkIf hw.nvidia.enable {
      # nvidia.sh. The Hyprland env (default/hypr/nvidia.lua) detects the GPU
      # itself.
      services.xserver.videoDrivers = [ "nvidia" ];
      hardware.nvidia = {
        modesetting.enable = true;
        open = mkDefault (!hw.nvidia.legacy);
        branch = mkIf hw.nvidia.legacy (mkDefault "legacy_580");
      };
      boot.initrd.kernelModules = [
        "nvidia"
        "nvidia_modeset"
        "nvidia_drm"
      ];
    })

    (mkIf hw.apple.t2.enable {
      # apple/fix-t2.sh (the kernel, firmware and audio parts are nixos-hardware's).
      boot.kernelParams = [
        "intel_iommu=on"
        "iommu=pt"
        "pm_async=off"
        "mem_sleep_default=deep"
      ];
      boot.kernelModules = [ "hci_bcm4377" ];
      warnings = optional (!(options.hardware ? apple-t2)) ''
        omnixy.hardware.apple.t2.enable is set but nixos-hardware's apple-t2
        module is not imported. Without the T2 kernel the keyboard, trackpad
        and audio do not work: add nixos-hardware.nixosModules.apple-t2.
      '';
    })
    (mkIf hw.apple.spiKeyboard.enable {
      # apple/fix-spi-keyboard.sh (applespi has been in mainline since 5.3).
      boot.initrd.availableKernelModules = [
        "applespi"
        "intel_lpss_pci"
        "spi_pxa2xx_platform"
        "spi_pxa2xx_pci"
      ];
    })

    (mkIf hw.surface.enable {
      # fix-surface-keyboard.sh. Upstream picks the loaded pinctrl module; here
      # udev loads whichever matches from the initrd.
      boot.initrd.availableKernelModules = [
        "surface_aggregator"
        "surface_aggregator_registry"
        "surface_aggregator_hub"
        "surface_hid_core"
        "surface_hid"
        "surface_kbd"
        "intel_lpss_pci"
        "8250_dw"
        "pinctrl_sunrisepoint"
        "pinctrl_cannonlake"
        "pinctrl_icelake"
        "pinctrl_tigerlake"
        "pinctrl_alderlake"
        "pinctrl_meteorlake"
      ];
    })

    (mkIf hw.broadcom.wl.enable {
      # fix-bcm43xx.sh
      boot.extraModulePackages = [
        (config.boot.kernelPackages.broadcom_sta.overrideAttrs (old: {
          meta = old.meta // {
            knownVulnerabilities = [ ];
          };
        }))
      ];
      boot.kernelModules = [ "wl" ];
      boot.blacklistedKernelModules = [
        "b43"
        "bcma"
        "ssb"
        "brcmsmac"
      ];
    })

    (mkIf hw.intel.pantherLake.enable {
      # intel/fred.sh
      boot.kernelParams = [ "fred=on" ];
    })
    (mkIf (hw.intel.ipu7 != null) {
      # intel/ipu7-camera.sh
      hardware.ipu7 = {
        enable = true;
        platform = hw.intel.ipu7;
      };
    })

    (mkIf hw.dell.xpsHapticTouchpad.enable {
      # dell-xps-touchpad-haptics.sh
      environment.systemPackages = [ haptics ];
      services.udev.packages = [ haptics ];
      systemd.services.dell-xps-touchpad-haptics = {
        description = "Dell XPS touchpad haptics";
        wantedBy = [ "multi-user.target" ];
        after = [ "systemd-udev-settle.service" ];
        # The daemon reads the level the CLI writes to
        # ~/.config/omarchy/dell-haptic.conf.
        environment.DELL_XPS_TOUCHPAD_HAPTICS_HOME = config.users.users.${cfg.user}.home;
        serviceConfig = {
          ExecStart = "${haptics}/bin/dell-xps-touchpad-haptics-daemon";
          Restart = "on-failure";
          RestartSec = 2;
        };
      };
    })

    (mkIf hw.tuxedo.enable {
      # fix-tuxedo-backlight.sh
      hardware.tuxedo-drivers.enable = true;
      boot.blacklistedKernelModules = [ "clevo_xsm_wmi" ];
    })

    (mkIf hw.motorcomm.yt6801.enable {
      # fix-yt6801-ethernet-adapter.sh
      boot.extraModulePackages = [ config.boot.kernelPackages.yt6801 ];
    })

    (mkIf (hw.wirelessRegdom != null) {
      # set-wireless-regdom.sh
      boot.extraModprobeConfig = "options cfg80211 ieee80211_regdom=${hw.wirelessRegdom}";
    })

    {
      assertions = [
        {
          assertion = !(hw.nvidia.legacy && !hw.nvidia.enable);
          message = "omnixy.hardware.nvidia.legacy needs omnixy.hardware.nvidia.enable.";
        }
      ]
      ++ optionals (!x86) [
        {
          assertion = !(hw.dell.xpsHapticTouchpad.enable || hw.intel.ipu7 != null);
          message = "The Dell haptics and Intel IPU7 options are x86_64 only.";
        }
      ];
    }
  ]);
}
