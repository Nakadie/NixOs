{
  lib,
  ...
}:
{
  # SSH access so the operator can reach the box over the tailnet.
  # No password auth — root key only.
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = lib.mkForce "prohibit-password";
      PasswordAuthentication = false;
    };
  };

  # Operator key for root login, from the local admin machine. Kept out of
  # this public repo as secrets/ssh_operator_key.pub (gitignored). Absolute
  # path because gitignored files do not survive the flake source copy.
  users.users.root.openssh.authorizedKeys.keyFiles = [
    /etc/nixos/secrets/ssh_operator_key.pub
  ];
}
