# omnixy-install, without a disk: shellcheck the script, then run --dry-run with
# every answer preset and check the files it generates.
{ pkgs }:
pkgs.runCommand "omnixy-install-dry-run"
  {
    nativeBuildInputs = [
      pkgs.shellcheck
      pkgs.omnixy-install
    ];
  }
  ''
    shellcheck -x ${./../packages/omnixy-install/omnixy-install}

    export OMNIXY_INSTALL_KEYBOARD="German" OMNIXY_INSTALL_USERNAME=alice \
      OMNIXY_INSTALL_PASSWORD=hunter2 OMNIXY_INSTALL_FULL_NAME='Alice "A" ''${x}' \
      OMNIXY_INSTALL_EMAIL=alice@example.com OMNIXY_INSTALL_HOSTNAME=wonderland \
      OMNIXY_INSTALL_TIMEZONE=UTC OMNIXY_INSTALL_DISK=/dev/vdb OMNIXY_INSTALL_ENCRYPT=yes
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
    grep -qF 'type = "luks";' out/disko.nix
    grep -qF 'device = "/dev/vdb";' out/disko.nix
    grep -qF '+ disko --mode destroy,format,mount' log
    grep -qF '+ nixos-install --root /mnt --flake /mnt/etc/nixos#wonderland --no-root-passwd' log
    touch $out
  ''
