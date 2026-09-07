{
  lib,
  ...
}:
{
  # SSH access so the operator can reach the box remotely after it
  # joins the tailnet. No password auth — root key only.
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = lib.mkForce "prohibit-password";
      PasswordAuthentication = false;
    };
    # Use the host key baked into the ISO so the fingerprint is stable
    # across reboots.
    hostKeys = [
      {
        path = "/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
    ];
  };

  # Operator public key is baked into the ISO at /root/.ssh/authorized_keys;
  # sshd reads the homedir authorized_keys by default (authorizedKeysInHomedir).

  # Trust the server's host key so `ssh user@nixos` doesn't prompt on first connect.
  programs.ssh.knownHosts.nixos = {
    hostNames = [
      "nixos"
      "100.121.224.67"
    ];
    publicKey = "AAAAC3NzaC1lZDI1NTE5AAAAIKLMeyUwpPB7tVqmTyeejaFSiNoA6pEfWJ8cx2A4yLuZ";
  };
}
