# Live ISO: boots straight into the OmniXY desktop as `omnixy` (password
# `omnixy`) with the NixOS installer tools available.
{
  lib,
  modulesPath,
  pkgs,
  ...
}:
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

  environment.systemPackages = with pkgs; [
    gparted
    disko
  ];
}
