{
  networking = {
    hostName = "backup-server";
    # Required by ZFS: the pool import at boot keys off the hostid.
    hostId = "3b83eaa3";
  };
}
