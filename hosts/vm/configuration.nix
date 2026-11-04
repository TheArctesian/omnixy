# Throwaway VM for trying OmniXY: `nix run .#vm` (user omnixy, password omnixy).
{ modulesPath, ... }:
{
  imports = [ (modulesPath + "/virtualisation/qemu-vm.nix") ];

  omnixy = {
    enable = true;
    user = "omnixy";
    fullName = "OmniXY";
    autoLogin = true;
    preinstalls.enable = false;
    features.plymouth = false;
  };
  users.users.omnixy.initialPassword = "omnixy";

  networking.hostName = "omnixy-vm";
  system.stateVersion = "26.05";

  virtualisation = {
    memorySize = 8192;
    cores = 4;
    diskSize = 16384;
    qemu.options = [
      "-device virtio-vga-gl"
      "-display gtk,gl=on"
    ];
  };
  # Software cursor; the virtio GPU has no hardware cursor plane under GL.
  environment.sessionVariables.WLR_NO_HARDWARE_CURSORS = "1";
}
