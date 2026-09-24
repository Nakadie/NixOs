{
  lib,
  ...
}:
{
  services.sanoid = {
    enable = true;
    # Run every minute so the hourly/daily/monthly boundaries are hit precisely
    # (sanoid --cron decides which tier is due).
    interval = "minutely";
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
