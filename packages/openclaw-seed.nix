# OpenClaw as Omarchy ships it: not OpenClaw itself but the *seed* a
# self-updating copy under ~/.openclaw is installed from (omarchy-pkgs
# pkgbuilds/openclaw). omarchy-install-openclaw-cli runs the install-cli.sh
# shipped here against openclaw.tgz, and that copy then replaces itself with
# `openclaw update` / the Control UI's Update button. A copy in the nix store
# could never do that, which is why this is not nixpkgs' openclaw.
#
# NixOS cannot run the Node build install-cli.sh downloads from nodejs.org (no
# /lib64/ld-linux-x86-64.so.2), so the installer is patched to link nixpkgs'
# Node, shipped beside it as share/openclaw/node, the same way it links the
# system Node on FreeBSD. The link goes through the path the script was run
# from (the nix profile), so the runtime follows this package's Node across
# upgrades.
{
  lib,
  stdenvNoCC,
  fetchurl,
  libarchive,
  nodejs_24,
  git,
  curl,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "openclaw";
  version = "2026.10.10";

  src = fetchurl {
    url = "https://registry.npmjs.org/openclaw/-/openclaw-${finalAttrs.version}.tgz";
    hash = "sha256-6BHBgoGBKkCeKaaBraf69xAFYAIOFE+98YiJ+rLHzwY=";
  };

  nativeBuildInputs = [ libarchive ];

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;
  # The installer is only ever run as `bash install-cli.sh`; patching its
  # `#!/usr/bin/env bash` is harmless but its re-exec guard is macOS-only.
  dontPatchShebangs = true;

  installPhase = ''
    runHook preInstall

    share=$out/share/openclaw
    install -Dm644 $src $share/openclaw.tgz

    bsdtar -xf $src 'package/scripts/install-*.sh' package/dist/control-ui/apple-touch-icon.png package/LICENSE
    install -Dm644 -t $share package/scripts/install-*.sh
    install -Dm644 package/dist/control-ui/apple-touch-icon.png $share/openclaw.png
    install -Dm644 -t $out/share/licenses/openclaw package/LICENSE
    ln -s ${nodejs_24} $share/node

    substituteInPlace $share/install-cli.sh \
      --replace-fail 'unset OPENCLAW_INSTALLER_REEXEC_FILE' 'unset OPENCLAW_INSTALLER_REEXEC_FILE
    # OmniXY: git and curl are what the installer would otherwise ask sudo for.
    export PATH="$PATH:${lib.makeBinPath [ git curl ]}"
    OMNIXY_NODE_BIN="$(cd "''${BASH_SOURCE[0]%/*}" && pwd)/node/bin"' \
      --replace-fail '  if [[ "$os" == "freebsd" ]]; then' '  # OmniXY: nodejs.org builds need an FHS loader NixOS does not have, so
      # the runtime runs on the nixpkgs Node shipped beside this installer.
      if [[ "$os" == "linux" && -x "$OMNIXY_NODE_BIN/node" ]]; then
        emit_json step name node status start method system
        if ! linked_node_is_usable "$OMNIXY_NODE_BIN/node" "$OMNIXY_NODE_BIN/npm"; then
          fail "The Node.js shipped with the OmniXY openclaw package cannot run this OpenClaw (needs ''${SUPPORTED_NODE_VERSION_LABEL}). Run omarchy-update, then retry."
        fi
        link_node_runtime_paths "$OMNIXY_NODE_BIN/node" "$OMNIXY_NODE_BIN/npm"
        emit_json step name node status ok method system version "$("$(node_bin)" -v)"
        return
      fi

      if [[ "$os" == "freebsd" ]]; then'

    # install-cli.sh loads its helpers from beside itself; fail the build, not
    # every setup, if that breaks.
    bash $share/install-cli.sh --help >/dev/null

    runHook postInstall
  '';

  passthru.node = nodejs_24;

  meta = {
    description = "Seed for Omarchy's self-updating OpenClaw install under ~/.openclaw";
    homepage = "https://github.com/openclaw/openclaw";
    license = lib.licenses.mit;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
})
