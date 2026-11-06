# ONCE, Basecamp's installer/manager for self-hosted web apps (Omarchy menu:
# Install › Service › ONCE). Mirrors omacom-io/omarchy-pkgs pkgbuilds/once-bin:
# the static release binary as `once`, plus Omarchy's once-background.service
# unit (expose it with `systemd.packages`; it needs Docker).
{
  lib,
  stdenvNoCC,
  fetchurl,
  makeWrapper,
  omarchyPkgsSrc,
}:
let
  version = "0.3.4";
in
stdenvNoCC.mkDerivation {
  pname = "once";
  inherit version;

  src = fetchurl {
    url = "https://github.com/basecamp/once/releases/download/v${version}/once-linux-amd64";
    hash = "sha256-B0xHsYuHmnRz3YpmwcqxV2w7uCt4i3ZLJNErhoy2DQE=";
  };

  licenseFile = fetchurl {
    url = "https://raw.githubusercontent.com/basecamp/once/v${version}/MIT-LICENSE";
    hash = "sha256-+g0UVDdcvHcBvBPZFsOuceYTuK5xgyFkHmeOCUCTk8Q=";
  };

  nativeBuildInputs = [ makeWrapper ];

  dontUnpack = true;
  dontBuild = true;
  dontStrip = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 $src $out/libexec/once/once
    # The self-updater would try to replace a read-only store path; updates
    # come with the flake instead, as the background unit already says.
    makeWrapper $out/libexec/once/once $out/bin/once --set-default ONCE_NO_SELF_UPDATE 1
    install -Dm644 $licenseFile $out/share/licenses/once/LICENSE
    install -Dm644 ${omarchyPkgsSrc}/pkgbuilds/once-bin/once-background.service \
      $out/lib/systemd/system/once-background.service
    substituteInPlace $out/lib/systemd/system/once-background.service \
      --replace-fail /usr/bin/once $out/bin/once
    runHook postInstall
  '';

  meta = {
    description = "CLI/TUI for installing and managing self-hosted web applications";
    homepage = "https://github.com/basecamp/once";
    license = lib.licenses.mit;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = "once";
    platforms = [ "x86_64-linux" ];
  };
}
