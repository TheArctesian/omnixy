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

    # The theme has no user field and logs in as SDDM's last user. Upstream
    # always autologins once at install, so that is set; a fresh NixOS install
    # without autoLogin has none and every login failed as user "". Fall back
    # to the first user SDDM lists (role 257 = Qt::UserRole + 1, NameRole).
    substituteInPlace $out/share/sddm/themes/omarchy/Main.qml --replace-fail \
      'property string currentUser: userModel.lastUser' \
      'property string currentUser: userModel.lastUser !== "" ? userModel.lastUser : userModel.data(userModel.index(0, 0), 257)'
  '';
  meta.license = lib.licenses.mit;
}
