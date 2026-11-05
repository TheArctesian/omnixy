{ omarchySrc, omarchyVersion }:
final: prev:
let
  # Omarchy's Arch packaging: launchers, desktop files and policies some of the
  # binary repackages below take verbatim.
  omarchyPkgsSrc = final.fetchFromGitHub {
    owner = "omacom-io";
    repo = "omarchy-pkgs";
    rev = "9043460ca583d8f012c75f2321bfc0f39cb3649e";
    hash = "sha256-A6Dx7Il6kvielsPBFPm0SliLVfHxrpsZeahb0h+omJo=";
  };
in
{
  omarchy = final.callPackage ./omarchy { inherit omarchySrc omarchyVersion; };
  omnixy-fonts = final.callPackage ./omnixy-fonts.nix { inherit omarchySrc omarchyVersion; };
  omnixy-sddm-theme = final.callPackage ./omnixy-sddm-theme.nix {
    inherit omarchySrc omarchyVersion;
  };
  omnixy-plymouth-theme = final.callPackage ./omnixy-plymouth-theme.nix {
    inherit omarchySrc omarchyVersion;
  };
  ttfx = final.callPackage ./ttfx.nix { };
  tensaku = final.callPackage ./tensaku.nix { };
  aether = final.callPackage ./aether.nix { };
  omazed = final.callPackage ./omazed.nix { };
  omarchy-nvim = final.callPackage ./omarchy-nvim.nix { };
  omarchy-emacs = final.callPackage ./omarchy-emacs.nix { };
  tobi-try = final.callPackage ./tobi-try.nix { };
  asdcontrol = final.callPackage ./asdcontrol.nix { };
  grok-bot = final.callPackage ./grok-bot.nix { inherit omarchyPkgsSrc; };
  once = final.callPackage ./once.nix { inherit omarchyPkgsSrc; };
  perplexity = final.callPackage ./perplexity.nix { inherit omarchyPkgsSrc; };
  zen-browser = final.callPackage ./zen-browser.nix { inherit omarchyPkgsSrc; };
  omacalc = final.callPackage ./oma-qt-app.nix {
    pname = "omacalc";
    version = "0.3.1";
    hash = "sha256-Q1LGLTmMz8jqPGptyp8oZKr3iCM2YTR0f/NbmPY8AFQ=";
    description = "Omarchy's dead-simple calculator";
  };
  omawrite = final.callPackage ./oma-qt-app.nix {
    pname = "omawrite";
    version = "0.7.2";
    hash = "sha256-kjbiI5Wo/vX9Fs3XnN1K3PWPOtOIX85ZLFOL1HBl6t0=";
    description = "Omarchy's dead-simple Markdown writing app";
  };
  omacut = final.callPackage ./oma-qt-app.nix {
    pname = "omacut";
    version = "0.7.2";
    hash = "sha256-bNu2S0BPDCjm9PQQUCSC7UGuACpP9vXbbHILlaSoI0s=";
    description = "Omarchy's dead-simple video trimmer";
    qtModules = [ "qtmultimedia" ];
    runtimePath = [ final.ffmpeg ];
    hasFonts = false;
  };
}
