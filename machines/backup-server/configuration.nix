{
  imports = [
    ./hardware-configuration.nix
    ./modules/backup-health.nix
    ./modules/beszel.nix
    ./modules/zfs.nix
    ./modules/environment.nix
    ./modules/netdata.nix
    ./modules/networking.nix
    ./modules/relay.nix
    ./modules/sanoid.nix
    ./modules/ssh.nix
    ./modules/syncoid.nix
    ./modules/tailscale.nix
    ./modules/users.nix
    ./modules/vscode-server.nix
    ./modules/watchdog.nix
  ];

  boot.loader = {
    systemd-boot = {
      enable = true;
      # Cap generations so /boot (511M) cannot fill up while unreachable.
      configurationLimit = 10;
    };
    efi.canTouchEfiVariables = true;
  };

  # Swap so an OOM spike cannot kill tailscaled/sshd on an unattended box.
  swapDevices = [
    {
      device = "/swapfile";
      size = 8192; # 8 GiB
    }
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Provide the VS Code server from nixpkgs so Remote-SSH does not try to
  # download one at runtime.
  services.vscode-server.enable = true;

  system.stateVersion = "26.05";
}
