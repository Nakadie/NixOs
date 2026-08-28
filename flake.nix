{
  description = "A simple NixOS flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    vscode-server.url = "github:nix-community/nixos-vscode-server";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    {
      self,
      nixpkgs,
      vscode-server,
      ...
    }@inputs:
    {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit inputs;
          unstable = import inputs.nixpkgs-unstable {
            config.allowUnfree = true;
            system = "x86_64-linux";
          };
        };
        modules = [
          vscode-server.nixosModules.default
          ./configuration.nix
          # Enable the service here as an inline module:
          (
            { config, pkgs, ... }:
            {
              services.vscode-server.enable = true;
            }
          )
        ];
      };
    };
}
