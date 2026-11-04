{ omarchySrc, omarchyVersion }:
final: prev: {
  omarchy = final.callPackage ./omarchy { inherit omarchySrc omarchyVersion; };
  omnixy-fonts = final.callPackage ./omnixy-fonts.nix { inherit omarchySrc omarchyVersion; };
  omnixy-sddm-theme = final.callPackage ./omnixy-sddm-theme.nix { inherit omarchySrc omarchyVersion; };
  omnixy-plymouth-theme = final.callPackage ./omnixy-plymouth-theme.nix { inherit omarchySrc omarchyVersion; };
  ttfx = final.callPackage ./ttfx.nix { };
  tensaku = final.callPackage ./tensaku.nix { };
}
