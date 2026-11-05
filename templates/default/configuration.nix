{ ... }:
{
  imports = [ ./hardware-configuration.nix ];

  omnixy = {
    enable = true;
    user = "alice"; # your username
    fullName = "Alice Example";
    email = "alice@example.com";
    theme = "Tokyo Night";
    # autoLogin = true;         # sensible with full-disk encryption
    # preinstalls.enable = false; # skip LibreOffice, OBS, Kdenlive, ...
    # features.docker = false;
  };

  networking.hostName = "omnixy"; # must match the name in flake.nix
  # Leave time.timeZone unset so the Omarchy timezone menu (timedatectl) can
  # change it; setting it here pins the zone declaratively.
  # time.timeZone = "Europe/London";
  i18n.defaultLocale = "en_GB.UTF-8";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  system.stateVersion = "26.05"; # don't change after install
}
