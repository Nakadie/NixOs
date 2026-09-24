{
  pkgs,
  ...
}:
let
  # Hub URL, token and key live in a gitignored file (this repo is public).
  beszel = import /etc/nixos/secrets/beszel.nix;
in
{
  systemd.services.beszel-agent = {
    description = "Beszel monitoring agent";
    after = [
      "network-online.target"
      "tailscaled.service"
    ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    # smartctl is required for the S.M.A.R.T. view.
    path = [ pkgs.smartmontools ];
    serviceConfig = {
      ExecStart = "${pkgs.beszel}/bin/beszel-agent";
      Restart = "always";
      RestartSec = 5;
      DynamicUser = true;
      # Read the disk device nodes, and talk S.M.A.R.T. to SATA (RAWIO) and
      # NVMe (SYS_ADMIN).
      SupplementaryGroups = [ "disk" ];
      AmbientCapabilities = [
        "CAP_SYS_RAWIO"
        "CAP_SYS_ADMIN"
      ];
      CapabilityBoundingSet = [
        "CAP_SYS_RAWIO"
        "CAP_SYS_ADMIN"
      ];
    };
    # Direct mode: the agent dials out to the hub, so no inbound port. The
    # attrset form keeps the spaces in the SSH key intact.
    environment = {
      HUB_URL = beszel.hubUrl;
      TOKEN = beszel.token;
      KEY = beszel.key;
    };
  };
}
