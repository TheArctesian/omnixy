# omnixy-install: the guided installer on the live ISO (see ./omnixy-install).
#
# omnixySource is the OmniXY source the ISO was built from, omnixyRev/
# nixpkgsRev the revisions; the installer locks the new system's flake to them
# so its closure mostly comes from the live store instead of being downloaded
# or rebuilt.
{
  lib,
  stdenvNoCC,
  makeWrapper,
  coreutils,
  curl,
  disko,
  gawk,
  gnugrep,
  gnused,
  gum,
  kbd,
  nixos-install-tools,
  openssl,
  tzupdate,
  util-linux,
  omnixySource ? null,
  omnixyRev ? null,
  nixpkgsRev ? null,
  stateVersion ? lib.trivial.release,
}:
stdenvNoCC.mkDerivation {
  pname = "omnixy-install";
  version = "1.0";

  src = ./.;
  nativeBuildInputs = [ makeWrapper ];
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    install -Dm755 omnixy-install $out/bin/omnixy-install
    install -Dm644 ${../../logo.txt} $out/share/omnixy-install/logo.txt
    install -Dm644 ${../../icon.png} $out/share/icons/hicolor/256x256/apps/omnixy-install.png

    mkdir -p $out/share/applications
    cat > $out/share/applications/omnixy-install.desktop <<EOF
    [Desktop Entry]
    Type=Application
    Name=Install OmniXY
    Comment=Install OmniXY to this computer's disk
    Exec=xdg-terminal-exec --app-id=org.omnixy.install --title="Install OmniXY" -e env OMNIXY_INSTALL_PAUSE=1 $out/bin/omnixy-install
    Icon=omnixy-install
    Terminal=false
    Categories=System;
    EOF

    runHook postInstall
  '';

  # The rest (sudo, nix, timedatectl, nmtui, hyprctl) comes from the live
  # system, so PATH is prefixed, not replaced.
  postFixup = ''
    wrapProgram $out/bin/omnixy-install \
      --prefix PATH : ${
        lib.makeBinPath [
          coreutils
          curl
          disko
          gawk
          gnugrep
          gnused
          gum
          kbd
          nixos-install-tools
          openssl
          tzupdate
          util-linux
        ]
      } \
      --set-default OMNIXY_INSTALL_LOGO $out/share/omnixy-install/logo.txt \
      --set-default OMNIXY_INSTALL_STATE_VERSION ${stateVersion} \
      ${lib.optionalString (omnixySource != null) "--set-default OMNIXY_INSTALL_OMNIXY_SOURCE ${omnixySource}"} \
      ${lib.optionalString (omnixyRev != null) "--set-default OMNIXY_INSTALL_OMNIXY_REV ${omnixyRev}"} \
      ${lib.optionalString (
        nixpkgsRev != null
      ) "--set-default OMNIXY_INSTALL_NIXPKGS_REV ${nixpkgsRev}"}
  '';

  meta = {
    description = "Guided OmniXY installer for the live ISO";
    homepage = "https://github.com/TheArctesian/omnixy";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "omnixy-install";
  };
}
