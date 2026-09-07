{
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    rsync
    exfatprogs
    ntfs3g
  ];
}
