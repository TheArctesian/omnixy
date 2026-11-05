# omarchy-settings' /etc and /usr/lib payload: fonts, fontconfig, plymouth,
# environment.d, mimeapps, chromium defaults, kernel/boot niceties.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.omnixy;
  src = pkgs.omarchy.upstreamSrc;
in
{
  config = lib.mkIf cfg.enable {
    fonts = {
      enableDefaultPackages = true;
      packages = with pkgs; [
        omnixy-fonts
        nerd-fonts.jetbrains-mono
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-color-emoji
        liberation_ttf
        font-awesome
        ia-writer-duospace
      ];
      fontconfig = {
        enable = true;
        defaultFonts = {
          monospace = [ "JetBrainsMono Nerd Font" ];
          sansSerif = [ "Liberation Sans" ];
          serif = [ "Liberation Serif" ];
          emoji = [ "Noto Color Emoji" ];
        };
        localConf = builtins.readFile "${src}/default/fontconfig/conf.avail/50-omarchy.conf";
      };
    };

    boot.plymouth = lib.mkIf cfg.features.plymouth {
      enable = true;
      theme = "omarchy";
      themePackages = [ pkgs.omnixy-plymouth-theme ];
    };
    # omarchy-plymouth-current and the preview read the theme from the profile.
    environment.systemPackages = lib.mkIf cfg.features.plymouth [ pkgs.omnixy-plymouth-theme ];
    boot.consoleLogLevel = lib.mkIf cfg.features.plymouth (lib.mkDefault 3);
    boot.kernelParams = lib.mkIf cfg.features.plymouth [
      "quiet"
      "splash"
      "udev.log_level=3"
    ];

    environment.etc = {
      # Input method for XCompose (CapsLock compose key, emoji shortcuts).
      "environment.d/10-omarchy-fcitx.conf".source = "${src}/default/environment.d/10-omarchy-fcitx.conf";
      # Default applications (imv, mpv, evince, nautilus, chromium...).
      "xdg/mimeapps.list".source = "${src}/default/applications/mimeapps.list";
      # Chromium first run: follow system theme, skip the ToS dialog.
      "chromium/initial_preferences".text = builtins.toJSON {
        distribution.require_eula = false;
        browser.theme = {
          color_scheme = 0;
          color_scheme2 = 0;
        };
      };
    };

    # Input method: fcitx5 with GTK/Qt modules (omarchy-fcitx5.service starts
    # it; upstream's environment.d file above sets the IM variables).
    i18n.inputMethod = {
      enable = lib.mkDefault true;
      type = "fcitx5";
      fcitx5.waylandFrontend = true;
      fcitx5.addons = [ pkgs.fcitx5-gtk ];
    };

    # Hyprland's input.lua reads XKBLAYOUT/XKBVARIANT from /etc/vconsole.conf,
    # which NixOS does not write. Derive them from services.xserver.xkb.
    environment.etc."vconsole.conf".text = lib.mkForce ''
      KEYMAP=${config.console.keyMap}
      ${lib.optionalString (config.console.font != null) "FONT=${config.console.font}"}
      XKBLAYOUT=${config.services.xserver.xkb.layout}
      XKBVARIANT=${config.services.xserver.xkb.variant}
      XKBOPTIONS=${config.services.xserver.xkb.options}
    '';

    # The shell's browser theme sync writes a managed policy here.
    programs.chromium.enable = true;

    # Upstream's .bashrc bootstrap (system-wide here so it also works for users
    # who manage ~/.bashrc themselves).
    programs.bash.interactiveShellInit = ''
      if ! grep -qs 'default/bash/rc' "$HOME/.bashrc"; then
        source "${pkgs.omarchy.omarchyPath}/default/bash/rc"
      fi
    '';

    documentation.man.cache.enable = lib.mkDefault false;
    nix.settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
  };
}
