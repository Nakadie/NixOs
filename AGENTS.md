# AGENTS.md

## Rules

- Do not update the NixOS version number (e.g. `nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11"`) without explicit user approval.
- The NixOS flake stays on `nixos-24.11`. Only the `home-manager` input follows `nixpkgs-unstable`; do not unify them.

## Build & switch

- `rebuild` is aliased to `nh os switch` (configuration.nix `environment.shellAliases`).
- Activation requires root: use `sudo nh os switch /etc/nixos` (or `nh os switch /etc/nixos -H nixos`). Run from `/etc/nixos`.
- To validate without switching: `nix eval .#nixosConfigurations.nixos.config.system.build.toplevel.drvPath`.
- `nh` caches flake snapshots by git tree hash. After editing, `git add -A` first — otherwise a stale eval cache can surface errors that `nix eval --refresh` no longer shows.

## Formatting

- The formatter is `nixfmt-rfc-style`, but it is not on PATH yet (classic `nixfmt` is). Run:
  `nix run nixpkgs#nixfmt-rfc-style -- <file.nix> ...`

## Module layout

- One file per service/area, imported from `configuration.nix` (e.g. `agh.nix`, `caddy.nix`, `rclone.nix`, `samba.nix`).
- `systemPackages` lives in `configuration.nix`. Unstable-only packages (opencode, mcp-nixos, herdr) are referenced as `unstable.<name>`.

## Flake specifics (hard-won)

- `specialArgs` (`unstable`, `inputs`) only reach a module if the arg is **explicitly named** in its function signature, e.g. `{ config, pkgs, unstable, ... }`. `...` alone does NOT bind them — this cost a whole debugging session.
- `vscode-server` input has no `nixpkgs` input to follow (it's flake-parts based); do not add `vscode-server.inputs.nixpkgs.follows`.
- `kams-hm` (home-manager config repo) is **private**: it uses `git+https://` (not `github:`) and requires `~/.netrc` credentials. If a lock fetch 404s, that's the cause.
- Home-manager user config is imported from `kams-hm/linux/linux-home.nix` under `home-manager.users.hpserver`; `targets.genericLinux.enable` is forced `false` (NixOS) and username/homeDirectory overridden to `hpserver`.
