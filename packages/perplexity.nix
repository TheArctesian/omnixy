# Perplexity's desktop app (Omarchy menu: Install › AI › Perplexity). Mirrors
# omacom-io/omarchy-pkgs pkgbuilds/perplexity: the Electron tree from
# Perplexity's own .deb, plus Omarchy's launcher (Wayland by default, extra
# flags from ~/.config/perplexity-flags.conf) as `perplexity`.
{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  omarchyPkgsSrc,
  alsa-lib,
  at-spi2-atk,
  at-spi2-core,
  cairo,
  cups,
  dbus,
  expat,
  gdk-pixbuf,
  glib,
  gtk3,
  libappindicator-gtk3,
  libdrm,
  libgbm,
  libglvnd,
  libnotify,
  libpulseaudio,
  libsecret,
  libx11,
  libxcb,
  libxcomposite,
  libxdamage,
  libxext,
  libxfixes,
  libxkbcommon,
  libxrandr,
  libxscrnsaver,
  libxshmfence,
  libxtst,
  nspr,
  nss,
  pango,
  systemd,
  util-linux,
  vulkan-loader,
  xdg-utils,
}:
let
  version = "26.10.3+build141572";
in
stdenv.mkDerivation {
  pname = "perplexity";
  inherit version;

  # The pool answers 403 to a literal '+' in the URL.
  src = fetchurl {
    url = "https://packages.perplexity.ai/deb/pool/main/p/perplexity/perplexity_${
      lib.replaceStrings [ "+" ] [ "%2B" ] version
    }_amd64.deb";
    hash = "sha256-6EaOwVeYVZQAHwulx/ot9DQ8zuJM8acbTf2la/FgDY0=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [
    alsa-lib
    at-spi2-atk
    at-spi2-core
    cairo
    cups
    dbus
    expat
    gdk-pixbuf
    glib
    gtk3
    libdrm
    libgbm
    libnotify
    libsecret
    libx11
    libxcb
    libxcomposite
    libxdamage
    libxext
    libxfixes
    libxkbcommon
    libxrandr
    libxscrnsaver
    libxshmfence
    libxtst
    nspr
    nss
    pango
    stdenv.cc.cc.lib
    systemd
    util-linux
  ];

  # dlopen()ed by Chromium rather than linked.
  runtimeDependencies = [
    (lib.getLib systemd)
    libappindicator-gtk3
    libglvnd
    libpulseaudio
    vulkan-loader
  ];

  unpackPhase = ''
    runHook preUnpack
    ar x $src
    tar xf data.tar.xz
    runHook postUnpack
  '';

  dontBuild = true;
  dontStrip = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib $out/share
    cp -r opt/Perplexity $out/lib/perplexity
    cp -r usr/share/icons $out/share/icons
    install -Dm644 usr/share/applications/perplexity.desktop $out/share/applications/perplexity.desktop

    # The menu entry goes through the launcher so the flags file applies there
    # too; the scheme handler (MimeType=) stays upstream's.
    substituteInPlace $out/share/applications/perplexity.desktop \
      --replace-fail 'Exec=/opt/Perplexity/perplexity %U' 'Exec=perplexity %U'

    install -Dm755 ${omarchyPkgsSrc}/pkgbuilds/perplexity/perplexity-launcher.sh $out/bin/perplexity
    substituteInPlace $out/bin/perplexity \
      --replace-fail /opt/Perplexity/perplexity $out/lib/perplexity/perplexity
    patchShebangs $out/bin/perplexity
    wrapProgram $out/bin/perplexity --prefix PATH : ${lib.makeBinPath [ xdg-utils ]}

    install -Dm644 $out/lib/perplexity/LICENSE.electron.txt -t $out/share/licenses/perplexity
    runHook postInstall
  '';

  meta = {
    description = "Official Perplexity desktop app";
    homepage = "https://www.perplexity.ai";
    license = lib.licenses.unfree;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = "perplexity";
    platforms = [ "x86_64-linux" ];
  };
}
