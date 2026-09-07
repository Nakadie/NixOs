{
  modulesPath,
  flake,
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

    # Bake the OAuth client secret into the live image so tailscale
    # auto-connects on boot with zero input from the end user.
    contents = [
      {
        target = "/etc/tailscale-oauth";
        # Absolute path: secrets/ is gitignored, so relative paths would not
        # survive the flake source copy into the store.
        source = /etc/nixos/secrets/tailscale-oauth;
      }
      # Bake the SSH host key so every boot has the same fingerprint
      # (no known_hosts warnings across reboots).
      {
        target = "/etc/ssh/ssh_host_ed25519_key";
        source = /etc/nixos/secrets/ssh_host_ed25519_key;
      }
      # Operator public key for root login.
      {
        target = "/root/.ssh/authorized_keys";
        source = /etc/nixos/secrets/ssh_operator_key.pub;
      }
      # Time Machine directory-hardlink reconstruction script (dr0i fork).
      {
        target = "/root/copy-from-time-machine.sh";
        source = ./scripts/copy-from-time-machine.sh;
      }
      # Embed the flake so the ISO can be used with
      # `nixos-install --flake /config#minimal`
      {
        target = "/config";
        source = flake;
      }
    ];
  };
}
