{
  networking.hostName = "eva";

  time.timeZone = "UTC";
  i18n.defaultLocale = "en_DK.UTF-8";

  programs.vim.defaultEditor = true;

  imports = [
    ./modules/prometheus
    ./modules/nginx.nix
    ./modules/sshd.nix
    ./modules/sops.nix
    ./modules/telegraf.nix

    ../modules/ec2.nix
    ../modules/mosh.nix
    ../modules/openldap/replica.nix
    ../modules/promtail.nix
    ../modules/tracing.nix
  ];

  networking.retiolum = {
    ipv4 = "10.243.29.185";
    ipv6 = "42:0:3c46:8a42:2b1:5ef8:7562:676a";
  };

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "20.03";
}
