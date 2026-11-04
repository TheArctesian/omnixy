# Hyprland, uwsm, the OmniXY session, SDDM, portals, and the lock screen.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.omnixy;
in
{
  config = lib.mkIf cfg.enable {
    programs.hyprland = {
      enable = true;
      withUWSM = true;
      xwayland.enable = true;
    };

    # The OmniXY session: seeds missing user files, then
    # `uwsm start ... hyprland.desktop` exactly as upstream's omarchy.desktop.
    services.displayManager = {
      sessionPackages = [ pkgs.omarchy ];
      defaultSession = "omnixy";
      autoLogin = lib.mkIf cfg.autoLogin {
        enable = true;
        inherit (cfg) user;
      };
      sddm = {
        enable = lib.mkDefault true;
        package = pkgs.kdePackages.sddm;
        wayland.enable = true;
        theme = "omarchy";
        extraPackages = [ pkgs.kdePackages.qtsvg ];
      };
    };
    environment.systemPackages = [ pkgs.omnixy-sddm-theme ];

    xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
      config.hyprland = {
        default = [
          "hyprland"
          "gtk"
        ];
        "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
      };
    };
    xdg.terminal-exec = {
      enable = true;
      settings.Hyprland = [ "foot.desktop" ];
    };
    xdg.mime.enable = true;

    # The Quickshell lock screen authenticates through these PAM services
    # (upstream writes them in omarchy-apply-lock).
    security.pam.services = {
      omarchy-lock-password = { };
      omarchy-lock-fingerprint = lib.mkIf config.services.fprintd.enable {
        fprintAuth = true;
        unixAuth = false;
      };
      # Upstream drops gnome-keyring from SDDM so a password login doesn't
      # create an encrypted keyring that fights the passwordless default one.
      sddm.enableGnomeKeyring = false;
    };
    services.gnome.gnome-keyring.enable = true;
    security.polkit.enable = true;
    programs.dconf.enable = true;

    # Session-wide environment that upstream puts in uwsm's env.d.
    environment.sessionVariables = {
      OMARCHY_PATH = pkgs.omarchy.omarchyPath;
      OMNIXY_FLAKE = cfg.flake.path;
      OMNIXY_DEFAULT_THEME = cfg.theme;
      TERMINAL = "xdg-terminal-exec";
      NIXOS_OZONE_WL = "1";
      # Let plain `gsettings` (first-run, omarchy-theme-set) find the
      # org.gnome.desktop.interface schema outside wrapped GTK apps.
      XDG_DATA_DIRS = [
        "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}"
      ];
    }
    // lib.optionalAttrs (cfg.flake.host != null) { OMNIXY_HOST = cfg.flake.host; };
  };
}
