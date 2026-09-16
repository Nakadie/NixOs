{
  config,
  pkgs,
  ...
}:
let
  script = pkgs.writeTextFile {
    name = "backup-health";
    executable = true;
    destination = "/bin/backup-health";
    text = builtins.readFile ../scripts/backup-health.sh;
  };
in
{
  # Discord webhook for failure alerts (gitignored, never committed).
  environment.etc."backup-health/webhook".source = /etc/nixos/secrets/discord-webhook;

  systemd.services.backup-health = {
    description = "Verify the ZFS snapshot pipeline";
    after = [ "zfs.target" ];
    path = [
      pkgs.coreutils
      pkgs.gnused
      pkgs.gawk
      pkgs.curl
      pkgs.jq
      pkgs.openssh
      pkgs.systemd
      config.boot.zfs.package
    ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${script}/bin/backup-health";
    };
    environment = {
      DATASET = "storagePool8Tb/photos";
      POOL = "storagePool8Tb";
      TIMERS = "sanoid.timer";
    };
  };

  systemd.timers.backup-health = {
    description = "Run the backup health check";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*-*-* *:20,50:00";
      Persistent = true;
    };
  };
}
