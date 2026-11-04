# Example OmniXY host. Copy this directory into your own flake (see
# templates/default) and replace hardware-configuration.nix with the one
# `nixos-generate-config` wrote for your machine.
{ ... }:
{
  imports = [ ./hardware-configuration.nix ];

  omnixy = {
    enable = true;
    user = "omnixy";
    fullName = "OmniXY User";
    email = "omnixy@example.com";
    theme = "Tokyo Night";
  };

  # Set a password with `passwd` after first boot, or declare one here.
  users.users.omnixy.initialPassword = "omnixy";

  networking.hostName = "omnixy";
  time.timeZone = "Europe/London";
  i18n.defaultLocale = "en_GB.UTF-8";
  console.keyMap = "uk";
  services.xserver.xkb.layout = "gb";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  system.stateVersion = "26.05";
}
