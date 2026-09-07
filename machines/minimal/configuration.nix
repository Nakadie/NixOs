{
  imports = [
    ./isoImage.nix
    ./modules/networking.nix
    ./modules/ssh.nix
    ./modules/tailscale.nix
    ./modules/users.nix
    ./modules/environment.nix
  ];

  system.stateVersion = "24.11";
}
