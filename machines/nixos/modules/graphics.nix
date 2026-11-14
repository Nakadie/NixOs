{ pkgs, ... }:
{
  # Intel HD Graphics 630 (Kaby Lake iGPU). Enable the Mesa/VA-API stack so
  # hardware video decode/encode works — e.g. Jellyfin transcoding. Unlike AMD
  # (where hardware.graphics.enable alone is enough), Intel needs its userspace
  # VA-API driver: intel-media-driver (iHD) covers Gen 8 / Broadwell and newer.
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
    ];
  };
}
