# Upstream's etc/ drop-ins (omarchy-settings), mirrored declaratively:
# resolved, NetworkManager, oomd, logind, systemd manager, sysctl, modprobe,
# zswap, sudoers, docker daemon, plocate, gnupg, kitty, fastfetch, mise.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.omnixy;
  # The packaged copy has /usr/share/omarchy paths rewritten.
  etcSrc = "${pkgs.omarchy}/share/omarchy/etc";
  bin = "/run/current-system/sw/bin";
in
{
  config = lib.mkIf cfg.enable {
    # resolved.conf.d/10-disable-multicast.conf, 20-docker-dns.conf
    services.resolved.settings.Resolve = {
      LLMNR = lib.mkDefault "no";
      MulticastDNS = lib.mkDefault "no";
    }
    // lib.optionalAttrs cfg.features.docker { DNSStubListenerExtra = "172.17.0.1"; };

    # NetworkManager/conf.d/omarchy-wifi-powersave.conf
    networking.networkmanager.settings.connection."wifi.powersave" = lib.mkDefault 2;

    # oomd.conf.d/10-omarchy.conf
    systemd.oomd.settings.OOM = {
      DefaultMemoryPressureDurationSec = lib.mkDefault "20s";
      DefaultMemoryPressureLimit = lib.mkDefault "50%";
    };

    # logind.conf.d: the power key opens Omarchy's system menu instead.
    services.logind.settings.Login = {
      HandlePowerKey = lib.mkDefault "ignore";
      InhibitDelayMaxSec = lib.mkDefault 15;
    };

    # system.conf.d / user.conf.d: faster shutdown, higher open-file limit.
    systemd.settings.Manager = {
      DefaultTimeoutStopSec = lib.mkDefault "5s";
      DefaultLimitNOFILE = lib.mkDefault "65536:524288";
    };
    systemd.user.settings.Manager.DefaultLimitNOFILE = lib.mkDefault "65536:524288";
    systemd.services."user@".serviceConfig.TimeoutStopSec = lib.mkDefault "5s";

    # sysctl.d/99-omarchy-sysctl.conf (90-omarchy-file-watchers.conf is
    # already NixOS's default of 524288)
    # (swap tuning assumes zram, which OmniXY enables).
    boot.kernel.sysctl = lib.mapAttrs (_: lib.mkDefault) {
      "net.ipv4.tcp_mtu_probing" = 1;
      "vm.swappiness" = 150;
      "vm.vfs_cache_pressure" = 50;
      "vm.page-cluster" = 0;
      "vm.watermark_boost_factor" = 0;
      "vm.watermark_scale_factor" = 125;
      "vm.dirty_background_bytes" = 67108864;
      "vm.dirty_bytes" = 268435456;
      "vm.dirty_writeback_centisecs" = 1500;
    };

    # modprobe.d/omarchy-usb-autosuspend.conf, tmpfiles.d/omarchy-zswap.conf
    boot.extraModprobeConfig = "options usbcore autosuspend=-1";
    boot.kernelParams = lib.mkIf config.zramSwap.enable [ "zswap.enabled=0" ];

    # sudoers.d: passwd tries, and the password-free grants the shell's
    # one-click actions rely on (DNS presets, browser accent, timezone).
    # Omarchy also drops timed grants in /etc/sudoers.d
    # (omarchy-sudo-passwordless), so include it, and clear those at boot.
    security.sudo.extraConfig = ''
      Defaults passwd_tries=10
      @includedir /etc/sudoers.d
    '';
    security.sudo.extraRules = [
      {
        groups = [ "wheel" ];
        runAs = "root";
        commands =
          map
            (command: {
              inherit command;
              options = [ "NOPASSWD" ];
            })
            [
              "${bin}/omarchy-dns Cloudflare"
              "${bin}/omarchy-dns Google"
              "${bin}/omarchy-dns DHCP"
              "${bin}/omarchy-theme-set-browser-policy [0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]"
              "${bin}/timedatectl ^set-timezone [A-Za-z0-9_+][A-Za-z0-9_+.-]*(/[A-Za-z0-9_+][A-Za-z0-9_+.-]*)*$"
              # asdcontrol.sudoers: only the calls omarchy-brightness-display-apple makes.
              "${bin}/asdcontrol ^--detect (/dev/(usb/)?hiddev[0-9]+)( /dev/(usb/)?hiddev[0-9]+)*$"
              "${bin}/asdcontrol ^/dev/(usb/)?hiddev[0-9]+$"
              "${bin}/asdcontrol ^/dev/(usb/)?hiddev[0-9]+ -- [+-]?[0-9]{1,3}%$"
            ];
      }
    ];
    systemd.tmpfiles.rules = [
      "d /etc/sudoers.d 0750 root root -"
      # Mutable drop-in dirs for omarchy-dns (the main files are NixOS's).
      "d /etc/systemd/resolved.conf.d 0755 root root -"
      "d /etc/NetworkManager/conf.d 0755 root root -"
      "r! /etc/sudoers.d/99-omarchy-nopasswd-*"
    ];

    # docker/daemon.json; docker group for sudoless docker, as upstream.
    virtualisation.docker.daemon.settings = lib.mkIf cfg.features.docker {
      log-driver = "json-file";
      log-opts = {
        max-size = "10m";
        max-file = "5";
      };
      dns = [ "172.17.0.1" ];
      bip = "172.17.0.1/16";
    };
    users.users.${cfg.user}.extraGroups = lib.optional cfg.features.docker "docker";

    # plocate-updatedb.service.d/ac-only.conf
    systemd.services.update-locatedb.unitConfig.ConditionACPower = true;

    environment.etc = {
      "gnupg/dirmngr.conf".source = "${etcSrc}/gnupg/dirmngr.conf";
      "xdg/kitty/kitty.conf".source = "${etcSrc}/xdg/kitty/kitty.conf";
      "fastfetch/config.jsonc".source = "${etcSrc}/fastfetch/config.jsonc";
      "mise/conf.d/omarchy.toml".source = "${etcSrc}/mise/conf.d/omarchy.toml";
    };
  };
}
