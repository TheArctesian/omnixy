# OmniXY NixOS module: the declarative half of Omarchy.
#
# Upstream Omarchy configures a system with imperative install scripts
# (install/config, install/hardware, install/login) plus the omarchy-settings
# package. Each file in this directory replaces one slice of that:
#
#   desktop.nix   Hyprland + uwsm + SDDM + portals + the OmniXY session
#   packages.nix  omarchy-base.packages mapped to nixpkgs
#   services.nix  install/config/enable-services.sh, firewall, PAM, docker
#   system.nix    /etc drop-ins, fonts, plymouth, zram, environment
#   tuning.nix    upstream's etc/ drop-ins (sysctl, logind, oomd, sudoers...)
#   user.nix      the omnixy.user account and its user units
{ lib, ... }:
let
  inherit (lib) mkOption mkEnableOption types;
in
{
  imports = [
    ./desktop.nix
    ./packages.nix
    ./services.nix
    ./system.nix
    ./tuning.nix
    ./user.nix
  ];

  options.omnixy = {
    enable = mkEnableOption "OmniXY, the Omarchy desktop for NixOS";

    user = mkOption {
      type = types.str;
      example = "alice";
      description = "Primary user. OmniXY creates this account if it is not defined elsewhere.";
    };

    fullName = mkOption {
      type = types.str;
      default = "";
      description = "Used for git identity and the XCompose name shortcut (CapsLock, Space, n).";
    };

    email = mkOption {
      type = types.str;
      default = "";
      description = "Used for git identity and the XCompose email shortcut (CapsLock, Space, e).";
    };

    theme = mkOption {
      type = types.str;
      default = "Tokyo Night";
      example = "Catppuccin";
      description = ''
        Theme applied on the user's first login. Themes switch at runtime
        (Super+Ctrl+Shift+Space, or `omarchy-theme-set "<name>"`) without a
        rebuild, so this only seeds the initial choice.
      '';
    };

    autoLogin = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Log straight into the session. Upstream enables this on full-disk
        encrypted installs, where the disk password already authenticates you.
      '';
    };

    flake = {
      path = mkOption {
        type = types.str;
        default = "/etc/nixos";
        description = "Path to the system flake that `omarchy-update` updates and rebuilds.";
      };
      host = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "nixosConfigurations attribute to rebuild. Defaults to the hostname.";
      };
    };

    preinstalls.enable = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Install Omarchy's preinstalled desktop apps (LibreOffice, Obsidian,
        OBS, Kdenlive, Pinta, Xournal++, LocalSend, ...). Disable for a lean
        system; the core desktop and CLI tools stay.
      '';
    };

    features = {
      docker = mkEnableOption "Docker (rootful daemon, socket-activated, as upstream)" // {
        default = true;
      };
      printing = mkEnableOption "CUPS printing with network printer discovery" // {
        default = true;
      };
      bluetooth = mkEnableOption "Bluetooth" // {
        default = true;
      };
      plymouth = mkEnableOption "the Omarchy Plymouth boot splash" // {
        default = true;
      };
      firewall = mkEnableOption "the firewall (deny inbound except LocalSend)" // {
        default = true;
      };
      once = mkEnableOption "ONCE and its background service (Install › Service › ONCE; needs Docker)";
      nordvpn = mkEnableOption "the NordVPN daemon, with the user in the nordvpn group (Install › Service › NordVPN)";
    };
  };
}
