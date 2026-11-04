{
  lib,
  stdenvNoCC,
  omarchySrc,
  omarchyVersion,
}:
stdenvNoCC.mkDerivation {
  pname = "omnixy-sddm-theme";
  version = omarchyVersion;
  src = omarchySrc;
  dontBuild = true;
  dontWrapQtApps = true;
  installPhase = ''
    mkdir -p $out/share/sddm/themes
    cp -r default/sddm/omarchy $out/share/sddm/themes/omarchy
    install -Dm644 default/sddm/hyprland.lua $out/share/sddm/hyprland.lua
  '';
  meta.license = lib.licenses.mit;
}
