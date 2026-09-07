{
  config,
  pkgs,
  lib,
  unstable,
  inputs,
  ...
}:
let
  cfg = config.services.netdata;
in
{
  # The 24.11 module lacks `extraNdsudoPackages`; use the unstable one,
  # which also matches the unstable `netdataCloud` package below.
  disabledModules = [ "services/monitoring/netdata.nix" ];
  imports = [ "${inputs.nixpkgs-unstable}/nixos/modules/services/monitoring/netdata.nix" ];

  config = lib.mkMerge [
    {
      networking.firewall.allowedTCPPorts = [ 19999 ];

      services.netdata = {
        enable = true;

        package = unstable.netdataCloud.override {
          withNdsudo = true;
          withIpmi = false;
        };
        # https://learn.netdata.cloud/docs/configuring/daemon-configuration
        config = {
          web = {
            "bind to" = "192.168.8.206:19999";
          };
          cloud = {
            scope = "none";
          };
          health = {
            "enabled alarms" = "*";
          };

          plugins = {
            "timex" = "no";
            "idlejitter" = "no";
            "netdata monitoring" = "no";
            "debugfs" = "no";
            "ioping" = "no";
            "tc" = "no";
            "freeipmi" = "no";
          };

          "plugin:cgroups" = {
            "enable cpuacct cpu throttling" = "no";
            "enable cpuacct cpu shares" = "no";
            "enable swap memory" = "no";
            "enable cpu pressure" = "no";
            "enable memory full pressure" = "no";
          };

          "plugin:apps" = {
            "command options" = "without-users without-groups";
          };

          "plugin:proc" = {
            "/proc/sys/kernel/random/entropy_avail" = "no";
            "/proc/pressure" = "no";
            "/proc/interrupts" = "no";
            "/proc/softirqs" = "no";
            "/proc/net/softnet_stat" = "no";
            "/proc/net/stat/conntrack" = "no";
            "ipc" = "no";
          };

          "plugin:proc:/proc/stat" = {
            "cpu interrupts" = "no";
          };

          "plugin:proc:/proc/vmstat" = {
            "swap i/o" = "no";
            "disk i/o" = "no";
            "memory page faults" = "no";
            "out of memory kills" = "no";
            "transparent huge pages" = "no";
          };

          "plugin:proc:/proc/meminfo" = {
            "writeback memory" = "no";
            "slab memory" = "no";
            "hugepages" = "no";
            "transparent hugepages" = "no";
            "memory reclaiming" = "no";
            "cma memory" = "no";
          };

          "plugin:proc:/proc/net/dev" = {
            "speed for all interfaces" = "no";
            "duplex for all interfaces" = "no";
            "mtu for all interfaces" = "no";
          };

          "plugin:proc:/proc/net/sockstat" = {
            "ipv4 sockets" = "no";
            "ipv4 TCP sockets" = "no";
            "ipv4 UDP sockets" = "no";
            "ipv4 UDPLITE sockets" = "no";
            "ipv4 RAW sockets" = "no";
            "ipv4 FRAG sockets" = "no";
          };

          "plugin:proc:/proc/net/sockstat6" = {
            "ipv6 TCP sockets" = "no";
            "ipv6 UDP sockets" = "no";
            "ipv6 UDPLITE sockets" = "no";
            "ipv6 RAW sockets" = "no";
            "ipv6 FRAG sockets" = "no";
          };
        };

        configDir = {
          "go.d.conf" = pkgs.writers.writeYAML "netdata-go.d.conf" {
            modules = {
              dnsmasq = false;
              logind = false;
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
        };
      };
    }

    (lib.mkIf cfg.package.withNdsudo {
      services.netdata = {
        extraNdsudoPackages = with pkgs; [
          nvme-cli
          smartmontools
        ];

        configDir = {
          "go.d/nvme.conf" = pkgs.writers.writeYAML "netdata-nvme.conf" {
            jobs = [
              {
                name = "nvme";
                autodetection_retry = 30;
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
    })

    (lib.mkIf config.boot.zfs.enabled {
      services.netdata.configDir."go.d/zfs.conf" = pkgs.writers.writeYAML "netdata-zfs.conf" {
        jobs = [
          {
            name = "zfs";
            binary_path = lib.getExe' config.boot.zfs.package "zfs";
          }
        ];
      };
    })
  ];
}
