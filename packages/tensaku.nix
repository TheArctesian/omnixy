# Screenshot annotation editor used by omarchy-capture-screenshot
# (`tensaku-edit`) and the clipboard history.
{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  wrapGAppsHook4,
  libGL,
  libepoxy,
  gtk4,
  libadwaita,
  fontconfig,
  libxkbcommon,
  gtk4-layer-shell,
}:
rustPlatform.buildRustPackage rec {
  pname = "tensaku";
  version = "0.29.0";
  src = fetchFromGitHub {
    owner = "jondkinney";
    repo = "tensaku";
    rev = "v${version}";
    hash = "sha256-IAjvMaN0R+dPtdOR26uLYRT+yjpIz/ZA3V4pKa6nue4=";
  };
  cargoHash = "sha256-q+jS+NX/AKWwaidEQrJMF2hMW+UCb1XJ9zA9Tc5iH5A=";

  nativeBuildInputs = [
    pkg-config
    wrapGAppsHook4
  ];
  buildInputs = [
    libGL
    libepoxy
    gtk4
    libadwaita
    fontconfig
    libxkbcommon
    gtk4-layer-shell
  ];
  doCheck = false;

  buildFeatures = [ "ci-release" ];

  postInstall = ''
    install -Dm755 assets/tensaku-edit $out/bin/tensaku-edit
    substituteInPlace $out/bin/tensaku-edit --replace-fail "exec tensaku" "exec $out/bin/tensaku"
    install -Dm644 dev.tensaku.Tensaku.desktop $out/share/applications/dev.tensaku.Tensaku.desktop
    install -Dm644 assets/tensaku.svg $out/share/icons/hicolor/scalable/apps/dev.tensaku.Tensaku.svg
  '';

  meta = {
    description = "Screenshot annotation tool";
    homepage = "https://github.com/jondkinney/tensaku";
    license = lib.licenses.mpl20;
    mainProgram = "tensaku";
  };
}
