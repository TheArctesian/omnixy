# omarchy-emacs: Emacs config that follows the Omarchy theme and font
# (Install › Editor › Emacs). Upstream's scripts read /usr/share/omarchy-emacs
# and start the Arch emacs.service; here they use the package from the user's
# profile (so the shim in ~/.config/emacs survives updates) and link nixpkgs'
# emacs.service into the user's systemd.
{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  makeWrapper,
  coreutils,
  gnugrep,
}:
stdenvNoCC.mkDerivation rec {
  pname = "omarchy-emacs";
  version = "1.10.1";

  src = fetchFromGitHub {
    owner = "scottjones";
    repo = "omarchy-emacs";
    rev = "v${version}";
    hash = "sha256-jJ/RloVH3dBsSXFKOjLS0kl3Iiui5r7BPZqUQldqDr8=";
  };

  nativeBuildInputs = [ makeWrapper ];
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    share=$out/share/omarchy-emacs
    mkdir -p $share/config/themes $share/hooks
    install -m644 config/init.el config/omarchy.el config/shell-bashrc $share/config/
    install -m644 config/themes/omarchy-theme.el $share/config/themes/
    install -m644 omarchy-colors.el.tpl $share/
    install -m755 hooks/font-set hooks/theme-set $share/hooks/
    install -Dm644 LICENSE $out/share/licenses/omarchy-emacs/LICENSE

    for f in omarchy-emacs-setup omarchy-emacs-sync-hooks omarchy-restart-emacs omarchy-install-emacs; do
      install -Dm755 bin/$f $out/bin/$f
    done

    # A stable path first (the profile link moves on update, the store path
    # does not), the store path as a fallback.
    for f in $out/bin/omarchy-emacs-setup $out/bin/omarchy-emacs-sync-hooks; do
      substituteInPlace $f --replace-fail 'SHARE_DIR="/usr/share/omarchy-emacs"' \
        'SHARE_DIR=@share@
    for d in "$HOME/.nix-profile/share/omarchy-emacs" "/etc/profiles/per-user/$USER/share/omarchy-emacs" "/run/current-system/sw/share/omarchy-emacs"; do
      [[ -d $d ]] && { SHARE_DIR=$d; break; }
    done'
      substituteInPlace $f --subst-var share
      # Store files are read-only; the user's copies must be editable.
      sed -i 's/^\(\s*\)cp "\$SHARE_DIR/\1cp --no-preserve=mode "$SHARE_DIR/' $f
    done

    substituteInPlace $out/bin/omarchy-install-emacs --replace-fail \
      'systemctl --user enable --now emacs.service' \
      'for unit in "$HOME/.nix-profile/lib/systemd/user/emacs.service" "/etc/profiles/per-user/$USER/lib/systemd/user/emacs.service"; do
      [[ -e $unit ]] && { systemctl --user link "$unit"; break; }
    done
    systemctl --user daemon-reload
    systemctl --user enable --now emacs.service'

    for f in $out/bin/*; do
      wrapProgram $f --suffix PATH : ${lib.makeBinPath [ coreutils gnugrep ]}:$out/bin
    done
    runHook postInstall
  '';

  meta = {
    description = "Emacs integration for Omarchy with automatic theme and font syncing";
    homepage = "https://github.com/scottjones/omarchy-emacs";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
}
