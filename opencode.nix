{ config, lib, pkgs, inputs, ... }:

let
  system = pkgs.stdenv.hostPlatform.system;
  unstable = inputs.nixpkgs-unstable.legacyPackages.${system};
in
{
  nixpkgs.overlays = [
    (final: prev: {
      opencode = unstable.opencode;
    })
  ];

  environment.systemPackages = with pkgs; [
    opencode
  ];
}