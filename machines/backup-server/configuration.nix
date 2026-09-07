{
  imports = [
    ./hardware-configuration.nix
    ./modules/zfs.nix
    ./modules/environment.nix
    ./modules/networking.nix
    ./modules/ssh.nix
    ./modules/tailscale.nix
  ];

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  system.stateVersion = "26.05";
}
