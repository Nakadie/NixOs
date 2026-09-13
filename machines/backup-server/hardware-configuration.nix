# PLACEHOLDER hardware config. The target box does not exist yet.
# Generate the real one on the machine with `nixos-generate-config`
# (booted from the minimal live USB) and replace this file before
# `nixos-install --flake /config#backup-server`. The by-id device names
# below are deliberately inert and must never be used as-is.
{
  config,
  lib,
  modulesPath,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [
    "ahci"
    "nvme"
    "usb_storage"
    "sd_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-id/REPLACE-with-nixos-generate-config-output";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-id/REPLACE-ESP";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
