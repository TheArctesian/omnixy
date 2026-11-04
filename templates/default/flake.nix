{
  description = "My NixOS system, running OmniXY";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    omnixy = {
      url = "github:TheArctesian/omnixy";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, omnixy, ... }:
    {
      # Rebuild with: sudo nixos-rebuild switch --flake /etc/nixos#omnixy
      # (or just `omarchy-update` once you're in the desktop)
      nixosConfigurations.omnixy = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          omnixy.nixosModules.default
          ./configuration.nix
        ];
      };
    };
}
