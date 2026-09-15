{
  imports = [
    ./hardware-configuration.nix
    ./modules/zfs.nix
    ./modules/environment.nix
    ./modules/netdata.nix
    ./modules/networking.nix
    ./modules/sanoid.nix
    ./modules/ssh.nix
    ./modules/syncoid.nix
    ./modules/tailscale.nix
    ./modules/users.nix
    ./modules/vscode-server.nix
  ];

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Provide the VS Code server from nixpkgs so Remote-SSH does not try to
  # download one at runtime.
  services.vscode-server.enable = true;

  system.stateVersion = "26.05";
}
