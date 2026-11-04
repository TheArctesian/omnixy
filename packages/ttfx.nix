# Terminal text effects, used by Omarchy's screensaver.
{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:
rustPlatform.buildRustPackage rec {
  pname = "ttfx";
  version = "0.5.1";
  src = fetchFromGitHub {
    owner = "omacom";
    repo = "ttfx";
    rev = "v${version}";
    hash = "sha256-/cECljrthspJsg6fgWMm4QIv8V3FJLuP/pbZoRKFVAc=";
  };
  cargoHash = "sha256-xSv2a0Q1biE20cOHkSOADxFfRNYKH/1MNCA03hQX9pE=";
  doCheck = false;
  meta = {
    description = "Terminal text effects as a single static binary";
    homepage = "https://github.com/omacom/ttfx";
    license = lib.licenses.mit;
    mainProgram = "ttfx";
  };
}
