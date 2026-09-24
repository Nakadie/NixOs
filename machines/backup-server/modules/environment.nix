{
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    # sanoid provides the snapshot manager and the syncoid pull binary.
    sanoid
    opencode
    git
  ];
}
