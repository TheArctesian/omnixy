# omarchy-nvim: Omarchy's LazyVim setup (LazyVim starter + Omarchy's lua/,
# plugin/ and lazyvim.json from omacom-io/omarchy-pkgs).
#
# Upstream's Arch package also ships a lazy.nvim plugin cache that it builds
# with network access; a Nix build cannot do that, so lazy.nvim clones the
# plugins on the first `nvim` start instead (it needs git and a network).
{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  makeWrapper,
  coreutils,
  xdg-utils,
}:
let
  starter = fetchFromGitHub {
    owner = "LazyVim";
    repo = "starter";
    rev = "803bc181d7c0d6d5eeba9274d9be49b287294d99";
    hash = "sha256-QrpnlDD4r1X4C8PqBhQ+S3ar5C+qDrU1Jm/lPqyMIFM=";
  };
in
stdenvNoCC.mkDerivation {
  pname = "omarchy-nvim";
  version = "2026.9.21";

  src = fetchFromGitHub {
    owner = "omacom-io";
    repo = "omarchy-pkgs";
    rev = "9043460ca583d8f012c75f2321bfc0f39cb3649e";
    hash = "sha256-A6Dx7Il6kvielsPBFPm0SliLVfHxrpsZeahb0h+omJo=";
  };

  nativeBuildInputs = [ makeWrapper ];
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    cfg=$out/share/omarchy-nvim/config
    mkdir -p $cfg
    cp -r ${starter}/. $cfg/
    chmod -R u+w $cfg
    rm -rf $cfg/.git $cfg/.github
    cp -r pkgbuilds/omarchy-nvim/lua pkgbuilds/omarchy-nvim/plugin $cfg/
    cp pkgbuilds/omarchy-nvim/lazyvim.json $cfg/
    install -Dm644 LICENSE $out/share/licenses/omarchy-nvim/LICENSE

    install -Dm755 ${./omarchy-nvim-setup} $out/bin/omarchy-nvim-setup
    substituteInPlace $out/bin/omarchy-nvim-setup --subst-var-by config $cfg
    wrapProgram $out/bin/omarchy-nvim-setup --prefix PATH : ${
      lib.makeBinPath [
        coreutils
        xdg-utils
      ]
    }
    # A symlink would not work: the wrapper hides the name it was run as.
    makeWrapper $out/bin/omarchy-nvim-setup $out/bin/omarchy-nvim-refresh --add-flags --force
    runHook postInstall
  '';

  meta = {
    description = "Omarchy's LazyVim configuration";
    homepage = "https://github.com/omacom-io/omarchy-pkgs/tree/master/pkgbuilds/omarchy-nvim";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
}
