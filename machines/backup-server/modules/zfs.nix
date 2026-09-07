{
  ...
}:
{
  boot = {
    supportedFilesystems.zfs = true;
    kernelModules = [
      "zfs" # ZFS support
    ];
    # Auto-import the shipped `backup` pool at boot. `zpool import backup`
    # is only needed on first boot, before this machine has a zpool.cache.
    zfs.extraPools = [ "backup" ];
    # No ZFS root pool here, so never force-import one at boot (default true
    # until 26.11; it bypasses ZFS's pool safeguards).
    zfs.forceImportRoot = false;
  };

  # Weekly scrub of the backup pool. Bitrot stays invisible until a restore
  # unless scrubbed; mirror the source server's autoscrub schedule.
  services.zfs.autoScrub = {
    enable = true;
    interval = "Thu *-*-* 04:00:00"; # Every Thursday at 4am
    pools = [ "backup" ];
  };
}
