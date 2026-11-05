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
