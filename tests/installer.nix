# omnixy-install, without a disk: shellcheck the script, then run --dry-run with
# every answer preset and check the files it generates.
{ pkgs }:
pkgs.runCommand "omnixy-install-dry-run"
  {
    nativeBuildInputs = [
      pkgs.shellcheck
      pkgs.omnixy-install
      pkgs.omarchy # omnixy-hardware-detect
    ];
  }
  ''
    shellcheck -x ${./../packages/omnixy-install/omnixy-install}

    # An empty fake machine: no hardware options apply.
    mkdir hw
    export OMNIXY_HW_ROOT=$PWD/hw
    export OMNIXY_INSTALL_KEYBOARD="German" OMNIXY_INSTALL_USERNAME=alice \
      OMNIXY_INSTALL_PASSWORD=hunter2 OMNIXY_INSTALL_FULL_NAME='Alice "A" ''${x}' \
      OMNIXY_INSTALL_EMAIL=alice@example.com OMNIXY_INSTALL_HOSTNAME=wonderland \
      OMNIXY_INSTALL_TIMEZONE=UTC OMNIXY_INSTALL_DISK=/dev/vdb OMNIXY_INSTALL_ENCRYPT=yes \
      OMNIXY_INSTALL_OMNIXY_SOURCE=/nix/store/00000000000000000000000000000000-source
    omnixy-install --dry-run --yes --out out </dev/null > log
    cat log

    c=out/etc-nixos/configuration.nix
    grep -qF 'nixosConfigurations."wonderland"' out/etc-nixos/flake.nix
    grep -qF 'url = "github:TheArctesian/omnixy";' out/etc-nixos/flake.nix
    grep -qF 'user = "alice";' $c
    grep -qF 'fullName = "Alice \"A\" \''${x}";' $c
    grep -qF 'initialHashedPassword = "$6$' $c
    grep -qF 'console.keyMap = "de";' $c
    grep -qF 'layout = "de";' $c
    grep -qF 'autoLogin = true;' $c
    grep -qF 'hardware = { };' $c
    grep -qF 'Hardware   none needed' log
    grep -qF 'type = "luks";' out/disko.nix
    grep -qF 'device = "/dev/vdb";' out/disko.nix
    grep -qF '+ disko --mode destroy,format,mount' log
    # The new system is locked to the ISO's own OmniXY source.
    grep -qF '+ nix flake lock /mnt/etc/nixos --override-input omnixy path:/nix/store/00000000000000000000000000000000-source' log
    grep -qF '+ nixos-install --root /mnt --flake /mnt/etc/nixos#wonderland --no-root-passwd' log

    # The regulatory domain follows the chosen timezone, not the live system's;
    # the result must still evaluate as Nix.
    TZDIR=${pkgs.tzdata}/share/zoneinfo OMNIXY_INSTALL_TIMEZONE=Europe/London \
      OMNIXY_INSTALL_ENCRYPT=no omnixy-install --dry-run --yes --out out2 </dev/null > log2
    grep -qF 'wirelessRegdom = "GB"; # from timezone Europe/London' out2/etc-nixos/configuration.nix
    grep -qF 'Hardware   wirelessRegdom' log2
    sed -n '/hardware = {$/,/^    };$/p' out2/etc-nixos/configuration.nix | sed -e '1s/.*/{/' -e '$s/.*/}/' > hw.nix
    cat hw.nix
    NIX_STATE_DIR=$TMPDIR/nix ${pkgs.nix}/bin/nix-instantiate --parse hw.nix >/dev/null
    touch $out
  ''
