{
  lib,
  ...
}:
{
  # Static hostname so the node appears consistently in the tailnet.
  networking.hostName = lib.mkForce "nixos-live";

  # installation-cd-base already enables DHCP on all wired interfaces
  # (plus wpa_supplicant for wireless), so networking is plug-and-play
  # on any remote machine without further config.
}
