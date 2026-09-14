{
  description = "Plug-and-play live USB ISO (auto tailscale join, key-only SSH)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
  };

  outputs =
    {
      self,
      nixpkgs,
      ...
    }:
    let
      system = "x86_64-linux";
    in
    {
      nixosConfigurations.minimal = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          # Embed this flake into the ISO at /config so it can be used with
          # `nixos-install --flake /config#minimal`
          flake = self;
        };
        modules = [
          ./configuration.nix
        ];
      };
    };
}
