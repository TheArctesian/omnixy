# Aether, the theme designer (Omarchy menu: Style › Aether). Upstream's Arch
# package ships the release binary; this builds the same Wails app from source:
# the Svelte frontend with npm, then the Go binary that embeds frontend/dist.
{
  lib,
  buildGoModule,
  buildNpmPackage,
  fetchFromGitHub,
  pkg-config,
  wrapGAppsHook3,
  gtk3,
  webkitgtk_4_1,
  glib-networking,
}:
let
  version = "4.32.0";
  src = fetchFromGitHub {
    owner = "bjarneo";
    repo = "aether";
    rev = "v${version}";
    hash = "sha256-Ntu2KRcEPyC4SvlFxW8PgdvijqH8OjljF60UuCvnWzg=";
  };

  frontend = buildNpmPackage {
    pname = "aether-frontend";
    inherit version src;
    sourceRoot = "${src.name}/frontend";
    npmDepsHash = "sha256-pKMbskfU6w1PO9eQvffoBk8HMmvrpkLZ3l6p6Y/czgU=";
    installPhase = ''
      runHook preInstall
      cp -r dist $out
      runHook postInstall
    '';
  };
in
buildGoModule {
  pname = "aether";
  inherit version src;
  vendorHash = "sha256-i8Tr4zKm+LaaZ/zKA8yoZC5mv2s4DUqaeT7Iq0uB+ME=";

  nativeBuildInputs = [
    pkg-config
    wrapGAppsHook3
  ];
  buildInputs = [
    gtk3
    webkitgtk_4_1
    glib-networking
  ];

  # go:embed needs frontend/dist; the module fetch does not.
  preBuild = ''
    rm -rf frontend/dist
    cp -r ${frontend} frontend/dist
  '';
  overrideModAttrs = _: { preBuild = ""; };

  tags = [
    "desktop"
    "production"
    "webkit2_41"
  ];
  ldflags = [
    "-s"
    "-w"
    "-X aether/cli.Version=${version}"
    # Aether's self-updater would overwrite its store path; point it at
    # omarchy-update instead, as upstream's packaged build does.
    "-X aether/internal/update.packageUpdateCommand=omarchy-update"
  ];
  subPackages = [ "." ];
  doCheck = false;

  postInstall = ''
    install -Dm644 li.oever.aether.desktop $out/share/applications/li.oever.aether.desktop
    install -Dm644 li.oever.aether.url-handler.desktop $out/share/applications/li.oever.aether.url-handler.desktop
    install -Dm644 assets/aether-icon-512.png $out/share/icons/hicolor/512x512/apps/aether.png
    install -Dm644 icon.png $out/share/pixmaps/aether.png
  '';

  meta = {
    description = "Desktop theming application: extract colours from a wallpaper and build an Omarchy theme";
    homepage = "https://github.com/bjarneo/aether";
    license = lib.licenses.mit;
    mainProgram = "aether";
    platforms = lib.platforms.linux;
  };
}
