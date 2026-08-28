# NixOS Configuration
# For help, see: configuration.nix(5) man page and nixos-help

{
  config,
  pkgs,
  unstable,
  ...
}:
{
  # ============================================================================
  # BASIC SYSTEM SETTINGS
  # ============================================================================

  imports = [
    ./hardware-configuration.nix
    ./caddy.nix
    ./agh.nix
    ./samba.nix
    ./rclone.nix
    ./netdata.nix
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # ============================================================================
  # BOOT & FILESYSTEMS
  # ============================================================================

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot = {
    supportedFilesystems = {
      zfs = true;
    };

    kernelModules = [
      "zfs" # ZFS support
    ];

    zfs.extraPools = [ "storagePool8Tb" ];

    kernelParams = [
      # ZFS ARC Cache: 8GB limit
      # https://openzfs.github.io/openzfs-docs/Performance%20and%20Tuning/Module%20Parameters.html#zfs-arc-max
      "zfs.zfs_arc_max=${builtins.toString (1024 * 1024 * 1024 * 8)}"
    ];
  };

  # Swapfile on the NVMe root filesystem (not the ZFS pool) — the system has 15 GiB RAM and no swap,
  # which let a memory spike hard-freeze the host (Aug 2026). NixOS creates the file on activation.
  swapDevices = [
    {
      device = "/swapfile";
      size = 16384; # 16 GiB
    }
  ];

  # ============================================================================
  # NETWORKING
  # ============================================================================

  networking = {
    hostName = "nixos";
    hostId = "984538cb";
    networkmanager.enable = true;

    # Firewall configuration
    firewall.allowedTCPPorts = [
      2283 # Immich
      8096 # Jellyfin
      8080 # Romm
    ];
  };

  # ============================================================================
  # LOCALIZATION & TIME
  # ============================================================================

  time.timeZone = "Asia/Tokyo";

  i18n = {
    defaultLocale = "en_US.UTF-8";

    extraLocaleSettings = {
      LC_ADDRESS = "ja_JP.UTF-8";
      LC_IDENTIFICATION = "ja_JP.UTF-8";
      LC_MEASUREMENT = "ja_JP.UTF-8";
      LC_MONETARY = "ja_JP.UTF-8";
      LC_NAME = "ja_JP.UTF-8";
      LC_NUMERIC = "ja_JP.UTF-8";
      LC_PAPER = "ja_JP.UTF-8";
      LC_TELEPHONE = "ja_JP.UTF-8";
      LC_TIME = "ja_JP.UTF-8";
    };
  };

  # ============================================================================
  # KEYBOARD & DISPLAY
  # ============================================================================

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # ============================================================================
  # USERS & GROUPS
  # ============================================================================

  users.users.hpserver = {
    isNormalUser = true;
    description = "hpserver";
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
      "docker-compose"
      "git"
      "vscode-server"
    ];
    packages = with pkgs; [ ];
  };

  # ============================================================================
  # PACKAGE MANAGEMENT
  # ============================================================================

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    # System utilities
    wget
    git
    bash
    coreutils
    openssl
    gh

    # Development tools
    nodejs_22
    nodePackages.npm
    nixfmt-rfc-style

    # CLI utilities & tools
    docker-compose
    fzf
    tealdeer
    direnv
    fastfetch
    bashmount
    nh

    # AI coding tools
    unstable.mcp-nixos

    # Backup & monitoring
    restic
    tailscale
    wgnord
    rsync

    # Media & applications
    gedit
    immich-cli
  ];

  # ============================================================================
  # SHELL ALIASES
  # ============================================================================

  environment.shellAliases = {
    rebuild = "nh os switch";
  };

  # services.restic.backups."paperless-documents" = {
  #   repository = "/storagePool8Tb/backups/restic";
  #   passwordFile = "/etc/nixos/restic-password";
  #   paths = [ "/storagePool8Tb/documents" ];
  #   timerConfig = {
  #     OnCalendar = "daily";
  #     Persistent = true;
  #   };
  #   pruneOpts = [
  #     "--keep-daily 7"
  #     "--keep-weekly 4"
  #     "--keep-monthly 6"
  #   ];
  #   extraBackupArgs = [
  #     "--exclude=.cache"
  #     "--exclude=Downloads"
  #   ];
  # };

  # ============================================================================
  # VIRTUALIZATION & SERVICES
  # ============================================================================

  virtualisation.docker.enable = true;

  services = {
    # SSH
    openssh.enable = true;

    # VS Code Server
    vscode-server.enable = true;

    # VPN
    tailscale.enable = true;

    # Storage
    zfs.autoScrub = {
      enable = true;
      interval = "Thu *-*-* 04:00:00"; # Every Thursday at 4am
    };
  };

  # ============================================================================
  # SYSTEM STATE
  # ============================================================================

  system.stateVersion = "24.11";
}
