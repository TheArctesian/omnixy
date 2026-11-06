# Hermes Desktop as Omarchy's hermes-desktop package provides it: the app
# (`hermes-desktop`, its desktop entry and icons) together with the `hermes`
# CLI it runs against.
#
# On Arch (omarchy-pkgs pkgbuilds/hermes-desktop) the package is a seed:
# upstream's install.sh plus a prebuilt Electron release, from which
# omarchy-install-hermes-cli builds a self-updating checkout under ~/.hermes
# with its own uv, CPython, Node and Electron, all downloaded as generic
# Linux binaries. NixOS runs none of those without nix-ld (no
# /lib64/ld-linux-x86-64.so.2, no libstdc++ for manylinux wheels), so this
# is Hermes' own Nix build instead (its flake's `default` CLI and `desktop`
# app, on nixpkgs' Electron), at the release the PKGBUILD packages. Hermes
# recognises a /nix/store install as managed, so it is updated by bumping
# the hermes-agent flake input, not by `hermes update`.
{
  lib,
  runCommand,
  imagemagick,
  # The hermes-agent flake's packages for this system.
  hermesAgentPackages,
}:

let
  cli = hermesAgentPackages.default;
  app = hermesAgentPackages.desktop;
in
runCommand "hermes-desktop-${cli.version or app.version}"
  {
    nativeBuildInputs = [ imagemagick ];
    passthru = { inherit cli app; };
    meta = {
      description = "Native desktop shell for Hermes Agent, with the hermes CLI";
      homepage = "https://github.com/NousResearch/hermes-agent";
      license = lib.licenses.mit;
      platforms = lib.platforms.linux;
      mainProgram = "hermes-desktop";
    };
  }
  ''
    mkdir -p $out/bin $out/share/applications
    for f in ${cli}/bin/*; do
      ln -s "$f" $out/bin/
    done
    ln -s ${app}/bin/hermes-desktop $out/bin/hermes-desktop

    # The PKGBUILD's entry: named after the package, since Omarchy's
    # launcher.hides drops entries called "hermes".
    cat > $out/share/applications/hermes-desktop.desktop <<EOF
    [Desktop Entry]
    Version=1.0
    Type=Application
    Name=Hermes
    GenericName=AI Agent
    Comment=The self-improving AI agent that grows with you
    Exec=hermes-desktop %U
    Icon=hermes-desktop
    Terminal=false
    Categories=Development;
    MimeType=x-scheme-handler/hermes;
    Keywords=ai;agent;assistant;hermes;nous;
    StartupNotify=true
    StartupWMClass=Hermes
    EOF

    icon=${app}/share/icons/hicolor/1024x1024/apps/hermes.png
    install -Dm644 $icon $out/share/icons/hicolor/1024x1024/apps/hermes-desktop.png
    for size in 512 256 128 64 48; do
      mkdir -p $out/share/icons/hicolor/''${size}x''${size}/apps
      magick $icon -resize ''${size}x''${size} $out/share/icons/hicolor/''${size}x''${size}/apps/hermes-desktop.png
    done
  ''
