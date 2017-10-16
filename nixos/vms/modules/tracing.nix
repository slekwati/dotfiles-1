{ pkgs, config, lib, ... }:
{
  programs.bcc.enable = true;
  programs.sysdig.enable = true;
  systemd.coredump.enable = true;

  environment.systemPackages = [
    pkgs.strace

    # we want to use trace from bcc
    (pkgs.lowPrio config.boot.kernelPackages.perf)
  ];
}
