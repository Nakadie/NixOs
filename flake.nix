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
    let
      system = "x86_64-linux";
      unstable = import inputs.nixpkgs-unstable {
        config.allowUnfree = true;
        inherit system;
      };
      specialArgs = {
        inherit inputs;
        inherit unstable;
      };
    in
    {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        inherit system;
        inherit specialArgs;
        modules = [
          vscode-server.nixosModules.default
          ./machines/nixos/configuration.nix
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
