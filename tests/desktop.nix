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
    { pkgs, ... }:
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
      # Preinstalls are off to keep the closure small; two of Omarchy's own
      # apps are enough to check the Qt Quick builds start.
      environment.systemPackages = [
        pkgs.omacalc
        pkgs.omawrite
        pkgs.pamtester
      ];

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
        # Software rendering is slow enough that Omarchy's 5-minute idle lock
        # can fire mid-test and swallow key presses. Stay awake.
        user("omarchy-toggle-idle stay-awake")
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

    with subtest("second theme switch keeps a complete theme"):
        user("omarchy-theme-set Gruvbox")
        machine.wait_until_succeeds("grep -qi gruvbox /home/alice/.local/state/omarchy/current/theme.name", timeout=60)
        machine.succeed("test -f /home/alice/.local/state/omarchy/current/theme/colors.toml")
        machine.fail("test -e /home/alice/.local/state/omarchy/current/theme/next-theme")

    with subtest("system parity"):
        # Audio helpers need pactl against PipeWire's Pulse server.
        print(user("pactl info | head -5"))
        # Hyprland's keyboard layout comes from vconsole.conf.
        machine.succeed("grep -q '^XKBLAYOUT=' /etc/vconsole.conf")
        # One-click DNS presets must not prompt for a password.
        print(user("sudo -n -l /run/current-system/sw/bin/omarchy-dns DHCP"))
        machine.succeed("test \"$(cat /proc/sys/vm/swappiness)\" = 150")
        machine.succeed("id -nG alice | grep -qw docker")
        # User units see the system profile (dbus-monitor for the sleep lock).
        machine.wait_until_succeeds("su - alice -c 'XDG_RUNTIME_DIR=/run/user/1000 systemctl --user is-active omarchy-sleep-lock'", timeout=30)
        machine.fail("journalctl -b | grep -q 'dbus-monitor: not found'")
        # Audio tuning's limiter is found by PipeWire, and root halves of
        # the sudo re-exec scripts can find coreutils.
        machine.succeed("test -f /run/current-system/sw/lib/lv2/lsp-plugins.lv2/limiter_stereo.ttl")
        machine.succeed("su - alice -c 'XDG_RUNTIME_DIR=/run/user/1000 systemctl --user show-environment' | grep -q '^LV2_PATH=/run/current-system/sw/lib/lv2'")
        machine.succeed("grep -q '^  export PATH=/run/current-system/sw/bin' /run/current-system/sw/bin/omarchy-dns")
        user("sudo -n /run/current-system/sw/bin/omarchy-dns Cloudflare")
        machine.succeed("grep -q '^DNS=1.1.1.1' /etc/systemd/resolved.conf.d/90-omarchy-dns.conf")
        machine.succeed("resolvectl status | grep -q 1.1.1.1")
        user("sudo -n /run/current-system/sw/bin/omarchy-dns DHCP")
        machine.succeed("grep -q '^DNSOverTLS=no' /etc/systemd/resolved.conf.d/90-omarchy-dns.conf")
        # First-run sets the git identity from omnixy.email (pam_env would
        # drop it because of the "@").
        machine.wait_until_succeeds("su - alice -c 'git config --global user.email' | grep -qx alice@example.com", timeout=120)
        machine.succeed("test -f /run/current-system/sw/share/icons/hicolor/256x256/apps/hey.png")
        print(user("omnixy-pkg resolve ttf-iosevka-nerd zed openssh libretro-mame"))

    with subtest("omarchy apps"):
        # Omarchy's LazyVim config is seeded when ~/.config/nvim is missing.
        machine.succeed("test -f /home/alice/.config/nvim/lua/plugins/omarchy-theme-hotreload.lua")
        machine.succeed("test -w /home/alice/.config/nvim/init.lua")
        machine.succeed("test -L /home/alice/.config/nvim/lua/plugins/theme.lua")
        machine.succeed("test -e /home/alice/.config/nvim/lua/plugins/theme.lua")
        print(user("omnixy-pkg resolve omacalc aether omazed omarchy-nvim"))
        machine.succeed("grep -q '\"id\": *\"omnixy\"' /etc/nix/registry.json")
        def wait_for_window(cls, timeout=120):
            for _ in range(timeout // 5):
                status, out = user("hyprctl -j clients", check=False)
                if status == 0 and cls in out.lower():
                    return
                machine.sleep(5)
            raise Exception(f"no {cls} window after {timeout}s")

        # Super+Ctrl+Q is Omarchy's calculator binding, Super+Shift+W Omawrite.
        machine.send_key("meta_l-ctrl-q")
        wait_for_window("omacalc")
        machine.sleep(10)
        machine.screenshot("05-omacalc")
        user("kill $(hyprctl -j clients | jq '.[] | select(.class == \"omacalc\") | .pid')")
        for _ in range(12):
            # Under TCG Hyprland's IPC can time out while it tears the window down.
            status, out = user("hyprctl -j clients", check=False)
            if status == 0 and "omacalc" not in out.lower():
                break
            machine.sleep(5)
        else:
            raise Exception("omacalc window did not close")
        machine.send_key("meta_l-shift-w")
        wait_for_window("omawrite")
        machine.sleep(10)
        machine.screenshot("06-omawrite")

    with subtest("faillock"):
        # increase-lockout-limit.sh: 10 wrong passwords lock the account for
        # 120 s; the lock screen's PAM stack is one that enforces it.
        pt = "pamtester omarchy-lock-password alice authenticate"
        faillock = "${pkgs.linux-pam}/bin/faillock --user alice"
        machine.succeed(f"echo alice | {pt}")
        for _ in range(10):
            machine.fail(f"echo wrong | {pt}")
        machine.fail(f"echo alice | {pt}")
        print(machine.succeed(faillock))
        machine.succeed(f"{faillock} --reset")
        machine.succeed(f"echo alice | {pt}")
        # sudo uses the same rules, and still authenticates.
        machine.succeed("grep -q 'pam_faillock.so.*authfail' /etc/pam.d/sudo")
        machine.succeed("echo alice | su - alice -c 'sudo -S -k true'")

    with subtest("optional installs"):
        # Base packages upstream ships, and the nixpkgs mappings for
        # Omarchy's install menu.
        print(user("try --help | head -3"))
        print(user("asdcontrol --about", check=False)[1])
        print(user("sudo -n -l /run/current-system/sw/bin/asdcontrol --detect /dev/hiddev0"))
        out = user("omnixy-pkg resolve t3code-bin openai-codex-desktop zen-browser-bin once-bin nordvpn-bin lutris openclaw omarchy-emacs emacs-wayland lib32-vulkan-radeon")
        print(out)
        assert "?" not in out, out
        machine.succeed("grep -q '/etc/zen/policies' /run/current-system/sw/bin/omarchy-install-browser")

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
