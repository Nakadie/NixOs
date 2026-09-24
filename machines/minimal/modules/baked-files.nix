{
  flake,
  ...
}:
{
  # On a NixOS ISO, `/` is a tmpfs and the ISO is mounted at `/iso`. Files
  # added with `isoImage.contents` land under `/iso`, so the live system never
  # sees them at their target paths. Place the baked secrets with NixOS-native
  # mechanisms instead: activation/tmpfiles write them into the tmpfs root.

  # Tailscale OAuth client secret. The module auto-starts
  # `tailscaled-autoconnect.service` when `authKeyFile` is set.
  environment.etc."tailscale-oauth".source = /etc/nixos/secrets/tailscale-oauth;

  # Operator SSH keys for root login.
  users.users.root.openssh.authorizedKeys.keyFiles = [
    /etc/nixos/secrets/ssh_operator_key.pub
  ];

  systemd.tmpfiles.rules = [
    # SSH host key. The store copy is 0444, but sshd requires 0600. Copy it
    # here (before sshd-keygen runs) so the fingerprint is stable across boots.
    "d /etc/ssh 0755 root root -"
    "C /etc/ssh/ssh_host_ed25519_key 0600 root root - ${/etc/nixos/secrets/ssh_host_ed25519_key}"
    # Time Machine directory-hardlink reconstruction script (dr0i fork).
    "C /root/copy-from-time-machine.sh 0755 root root - ${./../scripts/copy-from-time-machine.sh}"
    # Embed the flake so the ISO can be used with
    # `nixos-install --flake /config#minimal`.
    "L+ /config - - - - ${flake}"
  ];
}
