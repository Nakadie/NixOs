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
    description = "Verify the ZFS snapshot/syncoid pipeline";
    after = [ "zfs.target" ];
    path = [
      pkgs.bash
      pkgs.coreutils
      pkgs.gnugrep
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
      DATASET = "backup/photos";
      POOL = "backup";
      TIMERS = "sanoid.timer syncoid-pull.timer";
      # The box must hold the source's newest snapshot.
      PEER = "root@nixos";
      PEER_DATASET = "storagePool8Tb/photos";
    };
  };

  systemd.timers.backup-health = {
    description = "Run the backup health check";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*-*-* *:15,45:00";
      Persistent = true;
    };
  };
}
