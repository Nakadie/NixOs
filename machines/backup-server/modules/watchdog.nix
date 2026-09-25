{ ... }:
{
  # Software watchdog so an unattended, physically-unreachable box reboots
  # itself if the kernel or PID1 hangs. If the hardware already provides
  # /dev/watchdog, systemd uses it and softdog is unused.
  boot.kernelModules = [ "softdog" ];

  systemd.settings.Manager = {
    RuntimeWatchdogSec = "1min";
    RebootWatchdogSec = "10min";
  };
}
