# Omarchy's icon font (branded glyphs used by the shell and menus) and its
# fontconfig defaults (Liberation for sans/serif, JetBrainsMono Nerd Font for
# monospace).
{
  lib,
  stdenvNoCC,
  omarchySrc,
  omarchyVersion,
}:
stdenvNoCC.mkDerivation {
  pname = "omnixy-fonts";
  version = omarchyVersion;
  src = omarchySrc;
  dontBuild = true;
  installPhase = ''
    install -Dm644 default/fonts/omarchy/omarchy.ttf $out/share/fonts/truetype/omarchy/omarchy.ttf
    install -Dm644 default/fontconfig/conf.avail/50-omarchy.conf $out/etc/fonts/conf.d/50-omarchy.conf
  '';
  meta.license = lib.licenses.mit;
}
