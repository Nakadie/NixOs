{
  networking = {
    hostName = "backup-server";
    # Required by ZFS: the pool import at boot keys off the hostid.
    hostId = "3b83eaa3";
    # NetworkManager so WiFi can be configured with nmcli at runtime (the
    # PSK stays in a root-only file on the box, not in this repo).
    networkmanager.enable = true;

    # syncoid pulls as root@nixos. On-site the router resolves that name, but
    # off-site it will not, so pin it to the source's Tailscale address.
    hosts."100.121.224.67" = [ "nixos" ];
  };
}
