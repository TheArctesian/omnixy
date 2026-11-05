# omazed: keeps Zed's theme and font in step with the Omarchy theme, through
# Omarchy's theme-set.d / font-set.d hooks. Installed by
# omarchy-install-editor-zed, which then runs `omazed setup`.
{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  makeWrapper,
  jq,
  perl,
}:
stdenvNoCC.mkDerivation rec {
  pname = "omazed";
  version = "2.2.0";
  src = fetchFromGitHub {
    owner = "aps6";
    repo = "omazed";
    rev = "v${version}";
    hash = "sha256-RhZM4aCei6NbwuMehdwA94/81sXkQH1+kfq1TW0Lqtk=";
  };

  nativeBuildInputs = [ makeWrapper ];
  dontBuild = true;

  # The scripts look for their helpers next to themselves, as on Arch.
  installPhase = ''
    runHook preInstall
    install -Dm755 omazed omazed-generator.sh omazed-font.sh -t $out/bin
    install -Dm644 omazed-theme.tpl -t $out/bin
    install -Dm644 README.md -t $out/share/doc/omazed
    wrapProgram $out/bin/omazed --prefix PATH : ${
      lib.makeBinPath [
        jq
        perl
      ]
    }
    runHook postInstall
  '';

  meta = {
    description = "Live theme switching for Zed in Omarchy";
    homepage = "https://github.com/aps6/omazed";
    license = lib.licenses.mit;
    mainProgram = "omazed";
    platforms = lib.platforms.linux;
  };
}
