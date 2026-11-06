# install/config/enable-services.sh, firewall.sh, docker.sh, bluetooth.sh,
# network.sh and increase-lockout-limit.sh, declaratively.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.omnixy;
  f = cfg.features;
in
{
  config = lib.mkIf cfg.enable {
    # Networking: NetworkManager + resolved. Upstream masks
    # NetworkManager-wait-online so boot never blocks on Wi-Fi.
    networking.networkmanager = {
      enable = true;
      wifi.backend = lib.mkDefault "iwd";
    };
    systemd.services.NetworkManager-wait-online.enable = false;
    services.resolved.enable = true;

    # Firewall: deny inbound, allow LocalSend (53317 tcp/udp). Docker DNS is
    # handled by Docker's own iptables rules on NixOS.
    networking.firewall = lib.mkIf f.firewall {
      enable = true;
      allowedTCPPorts = [ 53317 ];
      allowedUDPPorts = [ 53317 ];
    };

    # Audio: PipeWire with Pulse/ALSA/JACK shims.
    services.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
      wireplumber.enable = true;
    };

    hardware.bluetooth = lib.mkIf f.bluetooth {
      enable = true;
      powerOnBoot = true;
    };

    services.printing = lib.mkIf f.printing {
      enable = true;
      browsed.enable = true;
    };
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };

    virtualisation.docker = lib.mkIf f.docker {
      enable = true;
      enableOnBoot = false; # socket-activated, like docker.socket upstream
    };

    # increase-lockout-limit.sh: Arch's system-auth locks an account for
    # 120 s after 10 failed passwords (pam_faillock). NixOS has no faillock
    # option, so add the same three rules around pam_unix in every stack that
    # asks for the password. sddm-autologin asks for none, as upstream.
    security.pam.services =
      let
        faillock = "${config.security.pam.package}/lib/security/pam_faillock.so";
        limits = {
          deny = 10;
          unlock_time = 120;
        };
        withFaillock = name: {
          rules.auth = {
            # NixOS's plain logFailures rule (on for su) would count twice.
            faillock.enable = lib.mkForce false;
            faillock-preauth = {
              order = config.security.pam.services.${name}.rules.auth.unix.order - 10;
              control = "required";
              modulePath = faillock;
              args = [ "preauth" "silent" ];
              settings = limits;
            };
            # pam_unix is "sufficient": a right password ends the stack, a
            # wrong one falls through to here, which records it and fails.
            faillock-authfail = {
              order = config.security.pam.services.${name}.rules.auth.unix.order + 10;
              control = "[default=die]";
              modulePath = faillock;
              args = [ "authfail" ];
              settings = limits;
            };
          };
          # Resets the count after a successful login.
          rules.account.faillock = {
            order = config.security.pam.services.${name}.rules.account.unix.order + 10;
            control = "required";
            modulePath = faillock;
          };
        };
      in
      lib.genAttrs (
        [
          "login"
          "sudo"
          "su"
          "polkit-1"
          "omarchy-lock-password"
        ]
        ++ lib.optional config.services.openssh.enable "sshd"
      ) withFaillock;

    # omarchy-install-service-nordvpn: nordvpnd plus the group its CLI needs.
    services.nordvpn.enable = lib.mkIf f.nordvpn true;
    users.users.${cfg.user}.extraGroups = lib.optional f.nordvpn "nordvpn";

    # omarchy-install-service-once: the CLI plus once-background.service.
    environment.systemPackages = lib.optional f.once pkgs.once;
    systemd.packages = lib.optional f.once pkgs.once;
    systemd.services.once-background.wantedBy = lib.mkIf f.once [ "multi-user.target" ];
    assertions = [
      {
        assertion = f.once -> f.docker;
        message = "omnixy.features.once needs omnixy.features.docker.";
      }
    ];

    services.power-profiles-daemon.enable = lib.mkDefault true;
    services.upower.enable = true;
    services.udisks2.enable = true;
    services.gvfs.enable = true;
    services.tumbler.enable = true;
    services.hardware.bolt.enable = true;
    services.fwupd.enable = lib.mkDefault true;
    services.locate = {
      enable = true;
      package = pkgs.plocate;
    };
    systemd.oomd = {
      enable = true;
      enableUserSlices = true;
    };
    zramSwap = {
      enable = lib.mkDefault true;
      memoryPercent = 100;
      algorithm = "zstd";
      priority = 100;
    };

    # gpu-screen-recorder needs cap_sys_admin for KMS capture.
    programs.gpu-screen-recorder.enable = true;
    programs.localsend.enable = lib.mkIf cfg.preinstalls.enable true;
    programs.nautilus-open-any-terminal = {
      enable = true;
      terminal = "foot";
    };
  };
}
