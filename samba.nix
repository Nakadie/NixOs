{ config, pkgs, ... }:

{
  # ============================================================================
  # SAMBA SMB/CIFS FILE SHARING
  # ============================================================================

  services.samba = {
    enable = true;
    package = pkgs.samba4Full;

    # Open firewall ports for Samba
    openFirewall = true;

    # Samba daemon configuration
    smbd.enable = true;
    nmbd.enable = true;

    # WINS name service
    nsswins = true;

    # Main Samba configuration
    settings = {
      global = {
        "workgroup" = "WORKGROUP";
        "server string" = "NixOS Samba Server";
        "netbios name" = "nixos";
        "security" = "user";
        "guest account" = "nobody";
        "map to guest" = "bad user";

        # Performance settings
        "socket options" = "TCP_NODELAY IPTOS_LOWDELAY SO_RCVBUF=131072 SO_SNDBUF=131072";
        "use sendfile" = true;
        "min receivefile size" = 16384;

        # Logging
        "log level" = 1;
        "max log size" = 50;
      };

      # Documents share
      documents = {
        "path" = "/storagePool8Tb/documents";
        "browseable" = true;
        "read only" = false;
        "guest ok" = false;
        "valid users" = "hpserver";
        "create mask" = "0755";
        "directory mask" = "0755";
      };
    };
  };

  # Create directories for shares if needed
  systemd.tmpfiles.rules = [
    # "d /var/samba/public 0755 root root -"
  ];
}
