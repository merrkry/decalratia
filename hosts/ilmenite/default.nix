{
  inputs,
  lib,
  user,
  ...
}:
{
  imports = (lib.mkModulesList ./.) ++ [ "${inputs.secrets}/ilmenite" ];

  profiles = {
    base = {
      enable = true;
      network.tailscale = "server";
    };
    base-devel.enable = true;
  };

  users.users = {
    ${user} = {
      openssh.authorizedKeys.keys = lib.sshKeys.trusted;
    };
  };

  time.timeZone = "Europe/Berlin";
}
