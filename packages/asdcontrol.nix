# asdcontrol: brightness for Apple Studio / XDR displays over USB HID
# (omarchy-brightness-display-apple). The sudoers grant upstream ships is in
# modules/tuning.nix.
{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation rec {
  pname = "asdcontrol";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "omakasui";
    repo = "asdcontrol";
    rev = "v${version}";
    hash = "sha256-kxzkZeoUZu3dUp/E95h5e8R/BMLakyIgoSug2j0jOR4=";
  };

  installPhase = ''
    runHook preInstall
    install -Dm755 asdcontrol $out/bin/asdcontrol
    runHook postInstall
  '';

  meta = {
    description = "Control brightness on Apple displays connected via USB-C";
    homepage = "https://github.com/omakasui/asdcontrol";
    license = lib.licenses.gpl2Only;
    mainProgram = "asdcontrol";
    platforms = lib.platforms.linux;
  };
}
