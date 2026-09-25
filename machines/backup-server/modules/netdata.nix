{
  config,
  lib,
  pkgs,
  ...
}:
let
  # Addresses live in a gitignored file (this repo is public).
  netdataIps = import /etc/nixos/secrets/netdata-ips.nix;
  # Stream this box's charts to the parent Netdata on the source server.
  parent = "${netdataIps.parentTs}:19999";
  streamKey = (import /etc/nixos/secrets/netdata-stream-key.nix).key;
in
{
  services.netdata = {
    enable = true;
    package = pkgs.netdata.override { withNdsudo = true; };

    config = {
      web = {
        # Local + Tailscale only (never the WAN side).
        "bind to" = "${netdataIps.childTs}:19999 127.0.0.1:19999";
      };
      cloud.scope = "none";
      health."enabled alarms" = "*";

      plugins = {
        "timex" = "no";
        "idlejitter" = "no";
        "netdata monitoring" = "no";
        "debugfs" = "no";
        "ioping" = "no";
        "tc" = "no";
        "freeipmi" = "no";
      };
    };

    extraNdsudoPackages = with pkgs; [
      smartmontools
      nvme-cli
    ];

    configDir = {
      "stream.conf" = pkgs.writeText "netdata-stream.conf" ''
        [stream]
            enabled = yes
            destination = ${parent}
            api key = ${streamKey}
            timeout seconds = 60
            default port = 19999
            reconnect delay seconds = 5
            initial clock resync iterations = 60
      '';

      "go.d.conf" = pkgs.writers.writeYAML "netdata-go.d.conf" {
        modules = {
          sensors = true;
        };
      };

      "go.d/sensors.conf" = pkgs.writers.writeYAML "netdata-sensors.conf" {
        jobs = [
          {
            name = "sensors";
          }
        ];
      };

      "go.d/zfs.conf" = pkgs.writers.writeYAML "netdata-zfs.conf" {
        jobs = [
          {
            name = "zfs";
            binary_path = lib.getExe' config.boot.zfs.package "zfs";
          }
        ];
      };

      "go.d/smartctl.conf" = pkgs.writers.writeYAML "netdata-smartctl.conf" {
        jobs = [
          {
            name = "smartctl";
            autodetection_retry = 30;
          }
        ];
      };
    };
  };
}
