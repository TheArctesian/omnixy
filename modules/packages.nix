# install/omarchy-base.packages, mapped to nixpkgs.
#
# Omarchy treats its default package set as runtime invariants: scripts call
# these commands directly without checking for them. So they are installed
# system-wide rather than wrapped into individual scripts.
#
# Not carried over (Arch-only or replaced by NixOS): yay, expac, fakeroot,
# pacman-contrib, kernel-modules-hook, qemu-user-static-binfmt, ufw/ufw-docker
# (networking.firewall), mise-bin (mise), omarchy-nvim (seeded LazyVim, see
# user.nix), dotnet-runtime, python-poetry-core, mariadb-libs. Not packaged
# for NixOS yet: aether, omacalc, omacut, omawrite, tobi-try, asdcontrol.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.omnixy;

  core = with pkgs; [
    omarchy
    omnixy-fonts
    ttfx
    tensaku

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
    fcitx5
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
  ];

  preinstalls = with pkgs; [
    libreoffice-fresh
    obsidian
    obs-studio
    kdePackages.kdenlive
    pinta
    xournalpp
    localsend
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
