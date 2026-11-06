# Synaptics haptic touchpad daemon for Dell XPS, from omacom-io/omarchy-pkgs
# (what install/hardware/dell-xps-touchpad-haptics.sh installs on Arch). The
# systemd unit lives in modules/hardware.nix; this ships the daemon, the
# `dell-xps-touchpad-haptics get|set` CLI the Omarchy menu calls, and the udev
# rules that keep the touchpad's I2C controller out of runtime suspend.
{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  bash,
  python3,
}:
stdenvNoCC.mkDerivation {
  pname = "dell-xps-touchpad-haptics";
  version = "1.0.0-5";

  src = fetchFromGitHub {
    owner = "omacom-io";
    repo = "omarchy-pkgs";
    rev = "9043460ca583d8f012c75f2321bfc0f39cb3649e";
    hash = "sha256-A6Dx7Il6kvielsPBFPm0SliLVfHxrpsZeahb0h+omJo=";
  };
  sourceRoot = "source/pkgbuilds/dell-xps-touchpad-haptics";

  buildInputs = [
    bash
    python3
  ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 dell-xps-touchpad-haptics -t $out/bin
    install -Dm755 dell-xps-touchpad-haptics-daemon -t $out/bin
    install -Dm644 99-dell-xps-touchpad-haptics.rules -t $out/lib/udev/rules.d
    install -Dm644 README.package.md $out/share/doc/dell-xps-touchpad-haptics/README.md
    runHook postInstall
  '';

  meta = {
    description = "Synaptics haptic touchpad presets for Dell XPS";
    homepage = "https://github.com/omacom-io/omarchy-pkgs";
    license = lib.licenses.mit;
    platforms = [ "x86_64-linux" ];
    mainProgram = "dell-xps-touchpad-haptics";
  };
}
