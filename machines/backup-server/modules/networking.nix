{
  networking = {
    hostName = "backup-server";
    # Required by ZFS: the pool import at boot keys off the hostid.
    hostId = "3b83eaa3";
    # NetworkManager so WiFi can be configured with nmcli at runtime (the
    # PSK stays in a root-only file on the box, not in this repo).
    networkmanager.enable = true;
  };
}
