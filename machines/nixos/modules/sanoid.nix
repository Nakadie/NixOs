{
  lib,
  ...
}:
{
  services.sanoid = {
    enable = true;
    # Matches the finest tier (hourly=24); --cron only acts when a tier is due.
    # OnCalendar=hourly fires at :00, ahead of the backup server's :05 syncoid pull.
    interval = "hourly";
    datasets."storagePool8Tb/photos" = {
      autosnap = true;
      autoprune = true;
      hourly = 24;
      daily = 30;
      monthly = 12;
    };
  };

  # The module hardcodes TZ=UTC to avoid DST shifting the tiers. Japan has no
  # DST, so use local time instead.
  systemd.services.sanoid.environment.TZ = lib.mkForce "Asia/Tokyo";
}
