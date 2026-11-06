# Grok Bot, xAI's desktop agent (Omarchy menu: Install › AI › Grok Bot).
# Mirrors omacom-io/omarchy-pkgs pkgbuilds/grok-bot: the Electron tree from
# the .deb on xAI's update feed, Omarchy's Wayland launcher as `grok-bot`
# (extra flags from ~/.config/grok-bot-flags.conf; `sand` is its old name) and
# Omarchy's desktop entry in place of the deb's.
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
  version = "0.78.5";
  # The Linux update feed names this commit; Cursor's apt pool lags it.
  commit = "87b31da762ca894e084ea1a069477801c85166a3";
in
stdenv.mkDerivation {
  pname = "grok-bot";
  inherit version;

  src = fetchurl {
    url = "https://downloads.cursor.com/grokbot/stable/${commit}/linux/x64/grok-bot_${version}_amd64.deb";
    hash = "sha256-MDx/qsnHvR9StSsmnTTut4Y5U0D+d7RaRee4hfYW4sw=";
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
    cp -r "opt/Grok Bot" $out/lib/grok-bot
    cp -r usr/share/icons $out/share/icons

    install -Dm755 ${omarchyPkgsSrc}/pkgbuilds/grok-bot/grok-bot.sh $out/bin/grok-bot
    substituteInPlace $out/bin/grok-bot --replace-fail "/opt/Grok Bot/" "$out/lib/grok-bot/"
    patchShebangs $out/bin/grok-bot
    wrapProgram $out/bin/grok-bot --prefix PATH : ${lib.makeBinPath [ xdg-utils ]}
    ln -s grok-bot $out/bin/sand

    install -Dm644 ${omarchyPkgsSrc}/pkgbuilds/grok-bot/grok-bot.desktop \
      $out/share/applications/grok-bot.desktop

    install -Dm644 -t $out/share/licenses/grok-bot \
      $out/lib/grok-bot/LICENSE.electron.txt $out/lib/grok-bot/LICENSES.chromium.html
    runHook postInstall
  '';

  meta = {
    description = "Grok Bot desktop agent";
    homepage = "https://x.ai/bot";
    license = lib.licenses.unfree;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = "grok-bot";
    platforms = [ "x86_64-linux" ];
  };
}
