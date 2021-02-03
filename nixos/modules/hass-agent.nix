{ ... }:
{
  users.extraUsers.hass-agent = {
    isSystemUser = true;
    extraGroups = [ "keys" ];
    shell = "/run/current-system/sw/bin/bash";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA6vG7qFCKcdlB+0PdLc2IY7dBmD26NcSEUVwaoqLFNB"
    ];
  };
}