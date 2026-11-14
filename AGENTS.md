# AGENTS.md

This repo is `/etc/nixos` on the live host `nixos`. Edits change the running system, not a throwaway checkout.

## Reference

The config is inspired by [`pedorich-n/home-server-nixos`](https://github.com/pedorich-n/home-server-nixos) (branch `main`). Consult it for module layout and service definitions before inventing a new structure; this repo is where the actual, machine-specific config lives.

## Rules

- Keep `nixpkgs` pinned to `nixos-26.05`. `nixpkgs-unstable` is a separate hand-imported input; do not unify the two.
- Do not bump `system.stateVersion` (`24.11` on nixos, `26.05` on the other machines). It records install history, not the channel.
- `machines/*/hardware-configuration.nix` is machine-generated; touch it only when the disks or hardware actually change.
- `secrets/` is gitignored and the GitHub repo is public. Never commit keys/webhooks, never inline their values in modules.
- Never run destructive operations on `/dev/sda` / `storagePool8Tb` without explicit approval — the full list is in the global `~/.config/opencode/AGENTS.md`.

## Evaluate & switch

Modules import secrets by absolute path (e.g. `import /etc/nixos/secrets/netdata-ips.nix`), so **every** flake command needs `--impure`; pure eval fails with "access to absolute path ... is forbidden".

- Switch: `nh os switch --impure -H nixos /etc/nixos` (alias `midori`). Run from `/etc/nixos`; `nh` elevates itself, do not prepend `sudo`.
- Validate without switching: `nix eval --impure .#nixosConfigurations.nixos.config.system.build.toplevel.drvPath`.
- `git add -A` before switching. `nh` snapshots the flake by git tree hash, so a dirty tree can serve a stale eval (untracked files are not even in the snapshot).
- Activation restarts every changed service, so the whole Docker stack bounces. netdata can exit `1` once with `Cannot bind ... port 19999 / Is Netdata already running?` while the outgoing agent releases its socket; `Restart=on-failure` recovers, but `switch-to-configuration` may already have returned 4. Just re-run the switch.

## Machines

Three separate flakes; only the root flake targets this host.

- `machines/nixos/` — the server. `configuration.nix` holds `environment.systemPackages`, the users, and the `midori`/`oaza` aliases. One file per service in `modules/`, wired in by hand in the `imports` list (no auto-discovery, so a new module does nothing until imported).
- `machines/backup-server/` — offsite box, own `flake.nix`/`flake.lock`. Deploy from this host (builds locally, copies, activates): `nh os switch --impure -H backup-server --target-host root@backup-server /etc/nixos/machines/backup-server` (alias `oaza`; `git add -A` first). `root@backup-server` resolves via `~/.ssh/config`.
- `machines/minimal/` — live ISO: boot straight to a root shell, Tailscale auto-join, SSH host key baked in. Build with `cd machines/minimal && nix build .#nixosConfigurations.minimal.config.system.build.isoImage --impure` after creating `secrets/tailscale-oauth` and `secrets/ssh_host_ed25519_key`.

`machines/nixos/configuration.nix` imports `../backup-server/modules/vscode-server.nix`, so that one file is shared by both hosts. Shell scripts run by systemd units live in `machines/<machine>/scripts/` and are read with `builtins.readFile` — editing one requires a switch to take effect.

Docker Compose stacks live under `/dockerConfigs/` and are managed outside this repo. The flake only enables Docker; do not nixify the containers here.

## Flake gotchas

- `specialArgs` (`unstable`, `inputs`, `vscodeServer`) reach a module only if its argument set names them, e.g. `{ config, pkgs, unstable, ... }`. `...` alone does not bind them.
- `vscode-server` depends only on `flake-parts`, so do not add `vscode-server.inputs.nixpkgs.follows`.
- Only `unstable.mcp-nixos` and `unstable.netdataCloud` come from the unstable set; everything else uses the pinned `pkgs`.
- Each flake updates independently: `nix flake update` at the root, and again inside `machines/backup-server/` and `machines/minimal/`.

## Formatting

`nixfmt` (RFC style, v1.5.0) is in `systemPackages` and all files currently pass `nixfmt --check`. Run `nixfmt <files...>` or `nix run nixpkgs#nixfmt -- <files...>`.
