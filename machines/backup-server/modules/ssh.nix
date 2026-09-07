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

  # The operator public key is provisioned on the host at
  # /root/.ssh/authorized_keys (the minimal live image bakes the same key in
  # via isoImage.contents); sshd reads the homedir authorized_keys by default.
}
