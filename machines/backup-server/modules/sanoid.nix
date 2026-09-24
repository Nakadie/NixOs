{
  lib,
  ...
}:
{
  # Prune-only: syncoid delivers the source's snapshots, so sanoid must not
  # create its own here. Keep longer than the source so history survives after
  # it rolls off the source.
  services.sanoid = {
    enable = true;
    interval = "minutely";
    datasets."backup/photos" = {
      autosnap = false;
      autoprune = true;
      hourly = 48;
      daily = 60;
      monthly = 24;
    };
  };

  # Japan has no DST, so use local time instead of the module's UTC default.
  systemd.services.sanoid.environment.TZ = lib.mkForce "Asia/Tokyo";
}
