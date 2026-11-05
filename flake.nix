{
  description = "OmniXY: Omarchy on NixOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Upstream Omarchy, consumed as plain source. Bumping this pin (and fixing
    # whatever the NixOS patches no longer apply to) is how OmniXY tracks
    # upstream releases. See docs/updating-upstream.md.
    omarchy = {
      url = "github:basecamp/omarchy/v4.0.6";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      omarchy,
    }:
    let
      system = "x86_64-linux";
      lib = nixpkgs.lib;

      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [ self.overlays.default ];
      };

      # Opt-in installs that nixpkgs gates behind a config flag, built here so
      # `omnixy-pkg` can install them from the menu like upstream does:
      # Lutris' FHS env still pulls gtk2 (marked broken as deprecated).
      pkgsOptIn = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
          problems.handlers."gtk+".broken = "warn";
        };
      };

      mkSystem =
        modules:
        lib.nixosSystem {
          inherit system;
          modules = [ self.nixosModules.default ] ++ modules;
        };
    in
    {
      # Keep in sync with the omarchy input's tag (upstream's own `version`
      # file is not bumped on release tags).
      overlays.default = import ./packages/overlay.nix {
        omarchySrc = omarchy;
        omarchyVersion = "4.0.6";
      };

      nixosModules = {
        default = self.nixosModules.omnixy;
        omnixy = {
          imports = [ ./modules ];
          nixpkgs.overlays = [ self.overlays.default ];
          # `omnixy#omacalc` etc. for omnixy-pkg, pinned to this source.
          nix.registry.omnixy.flake = self;
        };
      };

      nixosConfigurations = {
        # Template host. Copy hosts/example into your own flake (or /etc/nixos)
        # and replace hardware-configuration.nix with your generated one.
        example = mkSystem [ ./hosts/example/configuration.nix ];

        # Throwaway VM: `nix run .#vm`
        vm = mkSystem [ ./hosts/vm/configuration.nix ];

        # Live/installer ISO: `nix build .#iso`
        # The rev lets omnixy-install pin installs to the ISO's own source.
        iso = mkSystem [
          ./hosts/iso/configuration.nix
          { system.configurationRevision = self.rev or null; }
        ];
      };

      packages.${system} = {
        inherit (pkgs)
          omarchy
          omnixy-fonts
          ttfx
          tensaku
          aether
          omazed
          omarchy-nvim
          omarchy-emacs
          tobi-try
          asdcontrol
          omnixy-install
          omacalc
          omawrite
          omacut
          grok-bot
          once
          perplexity
          zen-browser
          ;
        inherit (pkgsOptIn) lutris;
        # Omarchy's openclaw package is the seed of a self-updating install in
        # ~/.openclaw, not nixpkgs' (store-bound) OpenClaw.
        openclaw = pkgs.callPackage ./packages/openclaw-seed.nix { };
        iso = self.nixosConfigurations.iso.config.system.build.isoImage;
        vm = self.nixosConfigurations.vm.config.system.build.vm;
        default = pkgs.omarchy;
      };

      apps.${system}.vm = {
        type = "app";
        program = "${self.packages.${system}.vm}/bin/run-omnixy-vm-vm";
      };

      checks.${system} = {
        example = self.nixosConfigurations.example.config.system.build.toplevel;
        desktop = import ./tests/desktop.nix { inherit pkgs self; };
        installer = import ./tests/installer.nix { inherit pkgs; };
      };

      templates.default = {
        path = ./templates/default;
        description = "A NixOS flake that imports OmniXY";
      };

      formatter.${system} = pkgs.nixfmt;

      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          nixfmt
          nil
          statix
          deadnix
          shellcheck
        ];
      };
    };
}
