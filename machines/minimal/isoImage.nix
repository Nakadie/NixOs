{
  modulesPath,
  lib,
  ...
}:
{
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-base.nix"
  ];

  # Needed for https://github.com/NixOS/nixpkgs/issues/58959
  # Read/mount whatever filesystem the remote machine's disks use.
  boot.supportedFilesystems = lib.mkForce [
    "btrfs"
    "reiserfs"
    "vfat"
    "f2fs"
    "xfs"
    "ntfs"
    "cifs"
    "hfs"
    "hfsplus"
    "exfat"
    "udf"
    "minix"
    "nfs"
    "squashfs"
  ];

  isoImage = {
    # Faster to build than the default (xz)
    squashfsCompression = "gzip";
  };
}
