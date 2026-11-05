# Omarchy's own Qt Quick apps (omacalc, omacut, omawrite) share one build:
# qmake + make, then the binary, icon and desktop file from pkgbuild/.
# Mirrors omacom-io/omarchy-pkgs pkgbuilds/<name>/PKGBUILD.
{
  lib,
  stdenv,
  fetchFromGitHub,
  qt6,
  pname,
  version,
  hash,
  description,
  qtModules ? [ ],
  runtimePath ? [ ],
  hasFonts ? true,
}:
stdenv.mkDerivation {
  inherit pname version;

  src = fetchFromGitHub {
    owner = "omacom-io";
    repo = pname;
    rev = "v${version}";
    inherit hash;
  };

  nativeBuildInputs = [
    qt6.qmake
    qt6.wrapQtAppsHook
  ];
  buildInputs = [
    qt6.qtbase
    qt6.qtdeclarative
    qt6.qtwayland
  ]
  ++ map (m: qt6.${m}) qtModules;

  installPhase = ''
    runHook preInstall
    install -Dm755 ${pname} $out/bin/${pname}
    install -Dm644 pkgbuild/${pname}.svg $out/share/icons/hicolor/scalable/apps/${pname}.svg
    install -Dm644 pkgbuild/${pname}.desktop $out/share/applications/${pname}.desktop
    install -Dm644 LICENSE $out/share/licenses/${pname}/LICENSE
    ${lib.optionalString hasFonts "install -Dm644 fonts/OFL.txt $out/share/licenses/${pname}/OFL.txt"}
    runHook postInstall
  '';

  qtWrapperArgs = lib.optionals (runtimePath != [ ]) [
    "--prefix PATH : ${lib.makeBinPath runtimePath}"
  ];

  meta = {
    inherit description;
    homepage = "https://github.com/omacom-io/${pname}";
    license = [ lib.licenses.mit ] ++ lib.optional hasFonts lib.licenses.ofl;
    mainProgram = pname;
    platforms = lib.platforms.linux;
  };
}
