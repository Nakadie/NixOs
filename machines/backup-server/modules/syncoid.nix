{
  config,
  pkgs,
  ...
}:
{
  # The backup server pulls from the source (never push from the source). The
  # key is authorized on the source as root, and the source's host key is
  # trusted below.
  systemd.services.syncoid-pull = {
    description = "Pull ZFS snapshots from the source server with syncoid";
    after = [
      "network-online.target"
      "tailscaled.service"
    ];
    wants = [ "network-online.target" ];
    path = [
      pkgs.openssh
      pkgs.sanoid
      pkgs.coreutils
      pkgs.mbuffer
      pkgs.pv
      config.boot.zfs.package
    ];
    serviceConfig = {
      Type = "oneshot";
      # --no-sync-snap: only transfer the source's sanoid snapshots.
      # --no-rollback: never force-rollback the target.
      ExecStart = "${pkgs.sanoid}/bin/syncoid --no-sync-snap --no-rollback root@nixos:storagePool8Tb/photos backup/photos";
    };
  };

  systemd.timers.syncoid-pull = {
    description = "Hourly syncoid pull from the source server";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      # After the source's :00 sanoid snapshot.
      OnCalendar = "*-*-* *:05:00";
      Persistent = true;
    };
  };

  # Trust the source's host key so the pull never prompts.
  programs.ssh.knownHosts.nixos = {
    hostNames = [ "nixos" ];
    publicKey = "AAAAC3NzaC1lZDI1NTE5AAAAIKLMeyUwpPB7tVqmTyeejaFSiNoA6pEfWJ8cx2A4yLuZ";
  };
}
