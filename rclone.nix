{ config, pkgs, ... }:

{
  # ============================================================================
  # RCLONE CLOUD STORAGE & MOUNTING
  # ============================================================================
  # Mounts remotes via FUSE using the "rclone" fstype in fileSystems.
  # Docs: https://wiki.nixos.org/wiki/Rclone

  environment.systemPackages = with pkgs; [
    rclone
  ];

  # Allow FUSE mounts by non-root users (needed for allow_other)
  programs.fuse.userAllowOther = true;

  # Remote config (create via `rclone config` as root, or declaratively here)
  # environment.etc."rclone-mnt.conf".text = ''
  #   [myremote]
  #   type = sftp
  #   host = 192.0.2.2
  #   user = myuser
  #   key_file = /root/.ssh/id_rsa
  # '';

  # Mount a remote at boot
  # fileSystems."/mnt" = {
  #   device = "myremote:/my_data";
  #   fsType = "rclone";
  #   options = [
  #     "nodev"
  #     "nofail"
  #     "allow_other"
  #     "args2env"
  #     "config=/etc/rclone-mnt.conf"
  #     "vfs-cache-mode=full"
  #     "dir-cache-time=10s"
  #   ];
  # };
}
