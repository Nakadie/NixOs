{
  ...
}:
{
  users.users.dadmin = {
    isNormalUser = true;
    description = "dadmin";
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    # Same operator keys as root (gitignored under /etc/nixos/secrets/).
    openssh.authorizedKeys.keyFiles = [
      /etc/nixos/secrets/ssh_operator_key.pub
    ];
  };

  # Login is key-only, so allow the admin user to sudo without a password.
  security.sudo.wheelNeedsPassword = false;
}
