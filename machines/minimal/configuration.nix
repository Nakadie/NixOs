{
  lib,
  ...
}:
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

  # Boot straight to a root shell: no boot-menu wait, no login prompt.
  boot.loader.timeout = lib.mkForce 1;
  services.getty.autologinUser = lib.mkForce "root";

  system.stateVersion = "26.05";
}
