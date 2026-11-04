# Upstream Omarchy, repackaged for NixOS.
#
# Omarchy on Arch is split into two packages: `omarchy` (bin/, shell/, themes/,
# migrations, install scripts -> /usr/share/omarchy) and `omarchy-settings`
# (/etc/skel seed, /etc drop-ins, fonts, plymouth, sddm). This derivation is
# the first one plus a prebuilt skel tree; the NixOS module in ../../modules
# covers the /etc half declaratively.
#
# OMARCHY_PATH is the stable profile path /run/current-system/sw/share/omarchy
# rather than this store path, so configs seeded into ~/.config keep working
# after upgrades and garbage collection.
{
  lib,
  stdenvNoCC,
  omarchySrc,
  omarchyVersion,
  bash,
  python3,
  gnused,
}:

let
  omarchyPath = "/run/current-system/sw/share/omarchy";

  # Commands that only make sense on Arch (pacman, AUR, limine, mkinitcpio,
  # the Arch ISO provisioning flow, the v3->v4 "Quattro" upgrade). They are
  # replaced by stubs that explain the NixOS equivalent, so menu entries and
  # muscle memory fail loudly instead of half-running.
  archOnly = [
    "omarchy-upgrade-to-quattro"
    "omarchy-refresh-pacman"
    "omarchy-refresh-limine"
    "omarchy-update-keyring"
    "omarchy-update-aur-pkgs"
    "omarchy-update-pacman-guard"
    "omarchy-update-pkg-prune"
    "omarchy-update-orphan-pkgs"
    "omarchy-update-system-pkgs-when-conflicted"
    "omarchy-update-firmware"
    "omarchy-pkg-aur-add"
    "omarchy-pkg-aur-install"
    "omarchy-reinstall-pkgs"
    "omarchy-channel-set"
    "omarchy-dev-pkg-test"
    "omarchy-dev-link"
    "omarchy-dev-unlink"
    "omarchy-apply-system"
    "omarchy-apply-hardware"
    "omarchy-provision-owner"
    "omarchy-hibernation-setup"
    "omarchy-hibernation-remove"
    "omarchy-toggle-hybrid-gpu"
    "omarchy-snapshot"
    "omarchy-system-factory-reset"
  ];
in
stdenvNoCC.mkDerivation {
  pname = "omarchy";
  version = omarchyVersion + "-omnixy";

  src = omarchySrc;

  # bash/python3 are here so patchShebangs rewrites #!/bin/bash and
  # #!/usr/bin/python3 to store paths.
  buildInputs = [
    bash
    python3
  ];
  nativeBuildInputs = [ gnused ];

  dontConfigure = true;
  dontBuild = true;

  passthru = {
    inherit omarchyPath archOnly;
    providedSessions = [ "omnixy" ];
    upstreamSrc = omarchySrc;
  };

  installPhase = ''
    runHook preInstall

    share=$out/share/omarchy
    mkdir -p $share $out/bin
    cp -r . $share
    chmod -R u+w $share
    rm -rf $share/.github $share/test $share/omarchy-pkgs
    echo "${omarchyVersion}" > $share/version

    # --- NixOS replacements -------------------------------------------------
    for name in ${lib.concatStringsSep " " archOnly}; do
      [[ -e $share/bin/$name ]] || continue
      cat > $share/bin/$name <<EOF
    #!/bin/bash
    # omarchy:summary=Not available on OmniXY (Arch-only)
    # omarchy:hidden=true
    echo "$name is Arch-specific and is not available on OmniXY." >&2
    echo "The NixOS equivalent is usually a change to your system flake followed by 'omarchy-update'." >&2
    echo "See https://github.com/TheArctesian/omnixy/blob/master/docs/differences.md" >&2
    exit 1
    EOF
    done
    cp -f ${./bin}/* $share/bin/
    chmod +x $share/bin/*

    # --- Path fixups ---------------------------------------------------------
    # /usr/share/omarchy -> stable profile path. /etc/skel -> our skel tree.
    grep -rlIZ -e '/usr/share/omarchy' -e '/etc/skel' -e '/usr/share/applications' -e ',/usr}/share/' $share | xargs -0 -r sed -i \
      -e 's|/usr/share/omarchy|${omarchyPath}|g' \
      -e 's|/usr/share/applications|/run/current-system/sw/share/applications|g' \
      -e 's|,/usr}/share/|,/usr,/run/current-system/sw}/share/|g' \
      -e 's|/etc/skel|/run/current-system/sw/share/omnixy/skel|g'

    # A few scripts hardcode Arch's /usr/bin for tools that live elsewhere here.
    grep -rlIZ -E '/usr/bin/(rm|mv|mktemp|install|timeout|hyprctl|signal-desktop|spotify|cursor|python3) ' $share/bin \
      | xargs -0 -r sed -i -E 's#/usr/bin/(rm|mv|mktemp|install|timeout|hyprctl|signal-desktop|spotify|cursor|python3)\b#\1#g'

    # --- Menu ----------------------------------------------------------------
    # Drop entries whose commands are Arch-only (children are found by key
    # prefix, so deleting the line removes the whole entry).
    menu=$share/default/omarchy/omarchy-menu.jsonc
    sed -i -E \
      -e '/^  "(install\.aur|update\.channel[^"]*|update\.firmware|update\.config\.plymouth|trigger\.hardware\.hybrid-gpu|system\.hibernate)":/d' \
      -e 's|("install\.package": \{[^}]*"label":)"Package"|\1"Package (nixpkgs)"|' \
      $menu

    # --- /etc/skel equivalent -------------------------------------------------
    skel=$out/share/omnixy/skel
    mkdir -p $skel/.config $skel/.local/share/applications \
      $skel/.local/state/omarchy/toggles/hypr $skel/.local/state/omarchy/migrations \
      $skel/.local/share/nautilus-python/extensions $skel/.local/state/tensaku \
      $skel/.config/omarchy/branding
    cp -r $share/config/. $skel/.config/
    cp -r $share/applications/*.desktop $skel/.local/share/applications/ 2>/dev/null || true
    cp $share/default/hypr/toggles/flags.lua $skel/.local/state/omarchy/toggles/hypr/
    cp $share/default/nautilus-python/extensions/*.py $skel/.local/share/nautilus-python/extensions/ 2>/dev/null || true
    [[ -f $share/default/tensaku/state.toml ]] && cp $share/default/tensaku/state.toml $skel/.local/state/tensaku/
    cp $share/default/bashrc $skel/.bashrc
    cp $share/logo.txt $skel/.config/omarchy/branding/about.txt
    cp $share/logo.txt $skel/.config/omarchy/branding/screensaver.txt
    # Upstream migrations repair Arch installs from older Omarchy releases.
    # A fresh OmniXY user starts with all of them applied, as the Arch ISO does.
    for m in $share/migrations/*.sh; do touch $skel/.local/state/omarchy/migrations/$(basename $m); done

    for f in $share/bin/*; do
      ln -s $f $out/bin/$(basename $f)
    done

    # --- systemd user units, desktop session, data files ----------------------
    mkdir -p $out/lib/systemd/user $out/share/wayland-sessions $out/share/xdg-terminal-exec $out/share/applications
    cp -r $share/default/systemd/user/. $out/lib/systemd/user/
    sed -i -e 's|/usr/bin/systemctl|/run/current-system/systemd/bin/systemctl|g' \
      -e 's|/usr/bin/|/run/current-system/sw/bin/|g' $out/lib/systemd/user/*.service
    cp $share/default/xdg-terminal-exec/*.list $out/share/xdg-terminal-exec/
    cat > $out/share/wayland-sessions/omnixy.desktop <<EOF
    [Desktop Entry]
    Name=OmniXY (Hyprland uwsm)
    Comment=Omarchy Hyprland session managed by uwsm
    Exec=$out/bin/omnixy-session
    TryExec=uwsm
    Type=Application
    DesktopNames=Hyprland
    EOF

    runHook postInstall
  '';

  # Make every script with a shebang executable before fixupPhase patches it.
  preFixup = ''
    find $out/share/omarchy -type f -name '*.sh' -exec grep -lIZ '^#!' {} + | xargs -0 -r chmod +x
  '';

  meta = {
    description = "Omarchy runtime (commands, Quickshell desktop, themes) packaged for NixOS";
    homepage = "https://github.com/basecamp/omarchy";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
  };
}
