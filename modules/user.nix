# The primary user, and the per-user systemd units upstream enables at first
# login (install/user/first-run/enable-user-units.sh).
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.omnixy;
  graphical = [ "graphical-session.target" ];
in
{
  config = lib.mkIf cfg.enable {
    users.users.${cfg.user} = {
      isNormalUser = lib.mkDefault true;
      description = lib.mkIf (cfg.fullName != "") cfg.fullName;
      extraGroups = [
        "wheel"
        "networkmanager"
        "video"
        "audio"
        "input"
        "lp"
        "scanner"
      ];
    };

    # Read by upstream's first-run (git identity, XCompose shortcuts).
    environment.sessionVariables = {
      OMARCHY_USER_NAME = cfg.fullName;
      OMARCHY_USER_EMAIL = cfg.email;
    };

    # Omarchy's own user units, shipped in the omarchy package.
    systemd.packages = [ pkgs.omarchy ];
    # Declaring a unit here also gives it NixOS's minimal default PATH, but
    # upstream's scripts call desktop tools (dbus-monitor, hyprctl, ...) by
    # name, so put the system and per-user profiles on it.
    systemd.user.services =
      lib.mapAttrs
        (
          _: unit:
          unit
          // {
            path = [
              "/run/current-system/sw"
              "/etc/profiles/per-user/${cfg.user}"
            ];
          }
        )
        {
          omarchy-sleep-lock.wantedBy = graphical;
          omarchy-fcitx5.wantedBy = graphical;
          omarchy-crash-watch.wantedBy = graphical;
          omarchy-recover-internal-monitor.wantedBy = [ "graphical-session-pre.target" ];
          bt-agent.wantedBy = lib.mkIf cfg.features.bluetooth graphical;
        };
    systemd.user.slices.app.sliceConfig = {
      ManagedOOMMemoryPressure = "kill";
      ManagedOOMSwap = "kill";
    };
  };
}
