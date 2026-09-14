{
  lib,
  pkgs,
  vscodeServer,
  ...
}:
let
  # Rebuild the upstream auto-fix script with our pkgs (same as the module does),
  # then patch out the handling that chokes on VS Code's new cli/servers layout.
  autoFix = pkgs.callPackage "${vscodeServer}/pkgs/auto-fix-vscode-server.nix" { };

  patched = pkgs.writeTextFile {
    name = "auto-fix-vscode-server-patched";
    executable = true;
    destination = "/bin/auto-fix-vscode-server";
    text = lib.replaceStrings
      [
        "-maxdepth 1 -type d -printf"
        "actual_dir=\"$bins_dir$bin\""
      ]
      [
        "-maxdepth 1 -not -name '.*' -type d -printf"
        "if [[ \"$bin\" == .* ]]; then continue; fi; actual_dir=\"$bins_dir$bin\""
      ]
      (builtins.readFile "${autoFix}/bin/auto-fix-vscode-server");
  };
in
{
  # Upstream's auto-fix script treats VS Code's new cli/servers/.locks
  # directory as a server, fails, and crash-loops -- which also breaks the
  # server install. Run a patched copy that skips dot-directories instead.
  systemd.user.services.auto-fix-vscode-server.serviceConfig.ExecStart =
    lib.mkForce "${patched}/bin/auto-fix-vscode-server";
}
