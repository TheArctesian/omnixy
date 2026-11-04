# End-to-end desktop test: boot, auto-login through SDDM into the OmniXY
# session, check Hyprland + the Quickshell desktop come up, exercise the
# terminal binding, the Omarchy menu and a runtime theme switch, and take
# screenshots of each step.
#
#   nix build .#checks.x86_64-linux.desktop -L
#   ls result/   # screenshots
{ pkgs, self }:
pkgs.testers.runNixOSTest {
  name = "omnixy-desktop";

  # The OmniXY module adds an overlay, so nodes need their own nixpkgs.
  node.pkgsReadOnly = false;

  nodes.machine =
    { ... }:
    {
      imports = [ self.nixosModules.default ];

      omnixy = {
        enable = true;
        user = "alice";
        fullName = "Alice Example";
        email = "alice@example.com";
        autoLogin = true;
        preinstalls.enable = false;
        features.plymouth = false;
      };
      users.users.alice.initialPassword = "alice";

      virtualisation = {
        memorySize = 6144;
        cores = 4;
        resolution = {
          x = 1920;
          y = 1080;
        };
        qemu.options = [ "-vga none -device virtio-gpu-pci,xres=1920,yres=1080" ];
      };
      # No GPU in the test VM: let wlroots/aquamarine render with llvmpipe.
      environment.sessionVariables = {
        WLR_RENDERER_ALLOW_SOFTWARE = "1";
        WLR_NO_HARDWARE_CURSORS = "1";
      };
    };

  testScript = ''
    import shlex

    def user(cmd, check=True):
        """Run a command as alice inside her Hyprland session environment."""
        env = (
            "export XDG_RUNTIME_DIR=/run/user/1000 WAYLAND_DISPLAY=wayland-1 "
            "HYPRLAND_INSTANCE_SIGNATURE=$(ls /run/user/1000/hypr | head -1) "
            "DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus; "
        )
        full = "su - alice -c " + shlex.quote(env + cmd)
        return machine.succeed(full) if check else machine.execute(full)

    start_all()

    with subtest("session starts"):
        machine.wait_for_unit("display-manager.service")
        try:
            machine.wait_until_succeeds("ls /run/user/1000/hypr/*/.socket.sock", timeout=420)
        except Exception:
            print(machine.execute("id alice; ps -eo user,pid,comm,args --sort=pid | grep -v '\\[' | tail -80")[1])
            print(machine.execute("ls -la /run/user/*/ /run/user/*/hypr 2>&1 | head -60")[1])
            print(machine.execute("su - alice -c 'XDG_RUNTIME_DIR=/run/user/$(id -u alice) systemctl --user status --no-pager wayland-wm@hyprland.desktop.service 2>&1 | tail -40'")[1])
            raise
        machine.wait_until_succeeds("test -S /run/user/1000/wayland-1", timeout=120)

    with subtest("user files were seeded"):
        machine.succeed("test -f /home/alice/.config/hypr/hyprland.lua")
        machine.succeed("test -f /home/alice/.bashrc")
        machine.succeed("test -w /home/alice/.config/hypr/hyprland.lua")
        machine.wait_until_succeeds("test -s /home/alice/.local/state/omarchy/current/theme.name", timeout=60)
        print(machine.succeed("cat /home/alice/.local/state/omarchy/current/theme.name"))

    with subtest("quickshell desktop is running"):
        machine.wait_until_succeeds("pgrep -u alice quickshell", timeout=120)
        # The shell logs its paths once QML is up; plugins (bar, menu,
        # background) register after that. Software rendering is slow, so
        # give them a generous margin before screenshotting.
        machine.wait_until_succeeds("journalctl -b -t omarchy-shell | grep -q 'omarchy-shell paths'", timeout=300)
        machine.sleep(60)
        machine.screenshot("01-desktop")
        print(user("hyprctl -j monitors"))

    with subtest("terminal binding"):
        machine.send_key("meta_l-ret")
        machine.wait_until_succeeds("pgrep -u alice -x foot", timeout=60)
        machine.sleep(5)
        machine.screenshot("02-terminal")

    with subtest("omarchy menu"):
        machine.send_key("meta_l-spc")
        machine.sleep(15)
        machine.screenshot("03-menu")
        machine.send_key("esc")

    with subtest("runtime theme switch"):
        user("omarchy-theme-set Catppuccin")
        machine.wait_until_succeeds("grep -qi catppuccin /home/alice/.local/state/omarchy/current/theme.name", timeout=60)
        machine.sleep(8)
        machine.screenshot("04-theme-catppuccin")

    with subtest("omarchy cli"):
        print(user("omarchy-version"))
        print(user("omarchy commands 2>&1 | head -40"))

    with subtest("collect logs"):
        print(machine.execute("ps -eo user,pid,args | grep -iE 'polkit|agent|nm-applet' | grep -v grep")[1])
        print(machine.execute("journalctl -b --no-pager -t omarchy-shell | grep -E 'WARN|ERROR' | tail -80")[1])
        print(machine.execute("su - alice -c 'XDG_RUNTIME_DIR=/run/user/1000 systemctl --user --failed --no-pager'")[1])
        print(machine.execute("su - alice -c 'cat ~/.local/state/omarchy/first-run.log' 2>&1 | tail -60")[1])
        print(user("gsettings get org.gnome.desktop.interface color-scheme", check=False)[1])
  '';
}
