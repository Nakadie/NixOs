{
  description = "Offsite backup server (ZFS + sanoid/syncoid, SSH, tailscale)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    vscode-server.url = "github:nix-community/nixos-vscode-server";
  };

  outputs =
    {
      self,
      nixpkgs,
      vscode-server,
      ...
    }:
    let
      system = "x86_64-linux";
    in
    {
      nixosConfigurations.backup-server = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          vscode-server.nixosModules.default
          ./configuration.nix
        ];
      };
    };
}
