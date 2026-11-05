# Zen, the Firefox-based browser (Omarchy menu: Install › Browser › Zen).
# Mirrors omacom-io/omarchy-pkgs pkgbuilds/zen-browser-bin: the official
# release tarball, launched as `zen-browser`, with upstream's zen.desktop and
# Omarchy's distribution/policies.json (no self-updates).
{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  patchelfUnstable,
  wrapGAppsHook3,
  omarchyPkgsSrc,
  adwaita-icon-theme,
  alsa-lib,
  cups,
  curl,
  dbus-glib,
  ffmpeg,
  gtk3,
  libdbusmenu-gtk3,
  libgbm,
  libglvnd,
  libkrb5,
  libnotify,
  libpulseaudio,
  libsecret,
  libva,
  libxscrnsaver,
  libxtst,
  pciutils,
  pipewire,
  speechd-minimal,
  udev,
  vulkan-loader,
}:
let
  version = "1.24b";
  libDir = "lib/zen-browser-bin";

  # What nixpkgs' wrapFirefox puts on LD_LIBRARY_PATH: Gecko dlopen()s all of
  # these at runtime.
  runtimeLibs = [
    cups
    ffmpeg
    libdbusmenu-gtk3
    libgbm
    libglvnd
    libkrb5
    libnotify
    libpulseaudio
    libsecret
    libva
    libxscrnsaver
    pciutils
    pipewire
    speechd-minimal
    udev
    vulkan-loader
  ];
in
stdenv.mkDerivation {
  pname = "zen-browser";
  inherit version;

  src = fetchurl {
    url = "https://github.com/zen-browser/desktop/releases/download/${version}/zen.linux-x86_64.tar.xz";
    hash = "sha256-Mj8mguc+OCR6UfvMdeVijtK7m0BNsAz5zxavMpqRb64=";
  };

  sourceRoot = "zen";

  nativeBuildInputs = [
    autoPatchelfHook
    patchelfUnstable
    wrapGAppsHook3
  ];
  buildInputs = [
    adwaita-icon-theme
    alsa-lib
    dbus-glib
    gtk3
    libxtst
  ];
  runtimeDependencies = [
    curl
    pciutils
    libva.out
  ];
  appendRunpaths = [ "${pipewire}/lib" ];
  # As nixpkgs' firefox-bin: keeps libxul.so's sections where Gecko expects them.
  patchelfFlags = [ "--no-clobber-old-sections" ];

  dontBuild = true;
  dontStrip = true;
  dontWrapGApps = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/${libDir}
    cp -r . $out/${libDir}

    # Updates come with the flake; the policy also hides the updater UI.
    install -Dm644 ${omarchyPkgsSrc}/pkgbuilds/zen-browser-bin/policies.json \
      $out/${libDir}/distribution/policies.json
    touch $out/${libDir}/is-packaged-app

    install -Dm644 ${omarchyPkgsSrc}/pkgbuilds/zen-browser-bin/zen.desktop \
      $out/share/applications/zen.desktop
    substituteInPlace $out/share/applications/zen.desktop \
      --replace-fail /opt/zen-browser-bin/zen-bin zen-browser

    for i in 16 32 48 64 128; do
      install -d $out/share/icons/hicolor/''${i}x''${i}/apps
      ln -s $out/${libDir}/browser/chrome/icons/default/default$i.png \
        $out/share/icons/hicolor/''${i}x''${i}/apps/zen-browser.png
    done
    runHook postInstall
  '';

  postFixup = ''
    makeWrapper $out/${libDir}/zen-bin $out/bin/zen-browser \
      "''${gappsWrapperArgs[@]}" \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath runtimeLibs} \
      --set MOZ_APP_LAUNCHER zen-browser \
      --set-default MOZ_ENABLE_WAYLAND 1
  '';

  meta = {
    description = "Privacy-focused, feature-packed Firefox-based web browser";
    homepage = "https://zen-browser.app";
    license = lib.licenses.mpl20;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = "zen-browser";
    platforms = [ "x86_64-linux" ];
  };
}
