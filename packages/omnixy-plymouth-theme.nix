{
  lib,
  stdenvNoCC,
  omarchySrc,
  omarchyVersion,
}:
stdenvNoCC.mkDerivation {
  pname = "omnixy-plymouth-theme";
  version = omarchyVersion;
  src = omarchySrc;
  dontBuild = true;
  installPhase = ''
    dir=$out/share/plymouth/themes/omarchy
    mkdir -p $dir
    cp default/plymouth/*.png default/plymouth/omarchy.script default/plymouth/omarchy.plymouth $dir/
    substituteInPlace $dir/omarchy.plymouth --replace-fail /usr/share/plymouth/themes/omarchy $dir
  '';
  meta.license = lib.licenses.mit;
}
