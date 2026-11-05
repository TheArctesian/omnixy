# install/omarchy-base.packages, mapped to nixpkgs.
#
# Omarchy treats its default package set as runtime invariants: scripts call
# these commands directly without checking for them. So they are installed
# system-wide rather than wrapped into individual scripts.
#
# Not carried over (Arch-only or replaced by NixOS): yay, expac, fakeroot,
# pacman-contrib, kernel-modules-hook, qemu-user-static-binfmt, ufw/ufw-docker
# (networking.firewall), mise-bin (mise), dotnet-runtime, python-poetry-core,
# mariadb-libs. Omarchy's own apps (aether, omacalc, omacut, omawrite,
# omarchy-nvim, omazed, omarchy-emacs) and tobi-try and asdcontrol are
# packaged in ../packages.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.omnixy;

  # Expose single binaries without the rest of a package: pactl without the
  # PulseAudio daemon (and its XDG autostart entry, PipeWire serves Pulse),
  # and LocalSend under the name Omarchy's scripts call.
  linkBin =
    name: target:
    pkgs.runCommand "omnixy-${name}" { } ''
      mkdir -p $out/bin
      ln -s ${target} $out/bin/${name}
    '';

  core = with pkgs; [
    omarchy
    omnixy-fonts
    ttfx
    tensaku
    omarchy-nvim
    tobi-try
    asdcontrol

    # Desktop
    quickshell
    uwsm
    hyprpicker
    hyprsunset
    hyprland-guiutils
    hyprland-preview-share-picker
    xdg-terminal-exec
    foot
    grim
    slurp
    wl-clipboard
    wtype
    brightnessctl
    ddcutil
    pamixer
    wireplumber
    alsa-utils
    playerctl
    libnotify
    swayosd
    gpu-screen-recorder
    udiskie
    nautilus
    nautilus-python
    sushi
    ffmpegthumbnailer
    gnome-disk-utility
    gnome-themes-extra
    yaru-theme
    adwaita-icon-theme
    evince
    imv
    mpv
    kdePackages.qtimageformats
    kdePackages.qtwayland
    libsecret
    gnome-keyring
    seahorse
    chromium
    system-config-printer
    bluez-tools
    iwgtk
    impala
    wiremix
    bluetui

    # Shell and CLI
    bash-completion
    bat
    btop
    eza
    fd
    fzf
    ripgrep
    zoxide
    starship
    fastfetch
    gum
    jq
    less
    man-db
    tldr
    tmux
    herdr
    neovim
    tree-sitter
    git
    lazygit
    lazydocker
    mise
    usage
    dua
    inxi
    whois
    inetutils
    inotify-tools
    socat
    unzip
    zip
    imagemagick
    vips
    qrencode
    zbar
    tesseract
    yt-dlp
    ffmpeg
    plocate
    dosfstools
    exfatprogs
    lua5_1
    lua51Packages.luarocks
    ruby
    clang
    llvm
    libyaml
    libpq
    python3
    python3Packages.pygobject3
    xdg-user-dirs
    dbus
    libxkbcommon
    glib # gsettings, used by first-run and theme scripts
    gsettings-desktop-schemas
    xdg-utils
    desktop-file-utils
    util-linux
    procps
    psmisc
    pciutils
    usbutils
    file
    curl
    wget
    gnused
    gawk
    bc
    cliamp
    tzupdate
    nss
    openssl
    # Called directly by shipped scripts (audio controls, network panel,
    # webcam capture, drive password, direct boot, launchers, icon caches).
    (linkBin "pactl" "${pulseaudio}/bin/pactl")
    iw
    v4l-utils
    cryptsetup
    efibootmgr
    # The limiter in omarchy-audio-tuning's filter chains: just the LV2
    # bundle, not lsp-plugins' JACK/VST/GStreamer builds (526 MB). The UI
    # library (which pulls those in) is left out: filter-chain never loads it.
    (pkgs.runCommand "lsp-plugins-lv2-${lsp-plugins.version}" { } ''
      mkdir -p $out/lib/lv2
      cp -r ${lsp-plugins}/lib/lv2/lsp-plugins.lv2 $out/lib/lv2/
      chmod -R u+w $out
      rm $out/lib/lv2/lsp-plugins.lv2/lsp-plugins-lv2ui.so
    '')
    gtk3 # gtk-launch, gtk-update-icon-cache
    hicolor-icon-theme
  ];

  # bin/omarchy-install-preinstalls: removable with omarchy-remove-preinstalls.
  preinstalls = with pkgs; [
    aether
    omacalc
    omacut
    omawrite
    libreoffice
    obsidian
    obs-studio
    kdePackages.kdenlive
    pinta
    xournalpp
    localsend
    (linkBin "localsend" "${localsend}/bin/localsend_app")
    moonlight-qt
    mpvScripts.mpris
  ];
in
{
  config = lib.mkIf cfg.enable {
    environment.systemPackages = core ++ lib.optionals cfg.preinstalls.enable preinstalls;

    # $OMARCHY_PATH and the skel tree live in the system profile so their
    # paths stay stable across rebuilds.
    environment.pathsToLink = [
      "/share/omarchy"
      "/share/omnixy"
      "/share/xdg-terminal-exec"
      "/share/sddm"
      "/share/nautilus-python"
    ];

    nixpkgs.config.allowUnfree = lib.mkDefault true;
  };
}
