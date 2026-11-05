# Live ISO: boots straight into the OmniXY desktop as `omnixy` (password
# `omnixy`) and opens the guided installer, omnixy-install, in a terminal
# (relaunch it from the app launcher as "Install OmniXY").
{
  config,
  lib,
  modulesPath,
  pkgs,
  ...
}:
let
  installer = pkgs.omnixy-install.override {
    # The OmniXY source this ISO was built from (already in its store, as the
    # `omnixy` registry entry).
    omnixySource = config.nix.registry.omnixy.flake.outPath;
    omnixyRev = config.system.configurationRevision;
    nixpkgsRev = config.system.nixos.revision;
  };
in
{
  imports = [ (modulesPath + "/installer/cd-dvd/installation-cd-graphical-base.nix") ];

  omnixy = {
    enable = true;
    user = "omnixy";
    fullName = "OmniXY Live";
    autoLogin = true;
    preinstalls.enable = false;
  };
  users.users.omnixy = {
    initialPassword = lib.mkForce "omnixy";
    initialHashedPassword = lib.mkForce null;
  };

  # The graphical base enables its own display manager defaults; OmniXY's SDDM wins.
  services.displayManager.sddm.enable = lib.mkForce true;
  networking.wireless.enable = lib.mkForce false;

  isoImage = {
    volumeID = lib.mkForce "OMNIXY";
    edition = lib.mkForce "omnixy";
  };
  image.baseName = lib.mkForce "omnixy-${pkgs.omarchy.version}";

  # The full preinstalls (LibreOffice, OBS, Kdenlive, ...) would add GBs;
  # Omarchy's own apps are small, so the live session has them.
  environment.systemPackages = with pkgs; [
    installer
    gparted
    disko
    aether
    omacalc
    omacut
    omawrite
    omazed
  ];
  # Greet the live session with the installer, as upstream's ISO does.
  environment.etc."xdg/autostart/omnixy-install.desktop".source =
    "${installer}/share/applications/omnixy-install.desktop";

  # Start the live session in "stay awake" (omarchy-toggle-idle), so the shell's
  # idle lock and screensaver don't lock the screen behind the live password or
  # blank it while an install runs. Each level is owned by the live user.
  systemd.tmpfiles.rules =
    map (dir: "d /home/omnixy/${dir} 0755 omnixy users -") [
      ".local"
      ".local/state"
      ".local/state/omarchy"
      ".local/state/omarchy/indicators"
    ]
    ++ [ "f /home/omnixy/.local/state/omarchy/indicators/stay-awake 0644 omnixy users -" ];
}
