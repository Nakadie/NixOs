{
  imports = [
    ./isoImage.nix
    ./modules/baked-files.nix
    ./modules/networking.nix
    ./modules/ssh.nix
    ./modules/tailscale.nix
    ./modules/users.nix
    ./modules/environment.nix
  ];

  system.stateVersion = "26.05";
}
