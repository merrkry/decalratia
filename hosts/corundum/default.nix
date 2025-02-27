{
  inputs,
  lib,
  user,
  ...
}:
{
  imports = (lib.mkModulesList ./.); # ++ [ "${inputs.secrets}/corundum" ];

  profiles = {
    base = {
      enable = true;
      network.tailscale = null; # "server";
    };
    base-devel.enable = true;
  };

  users.users = {
    ${user} = {
      hashedPassword = "$y$j9T$8oJJAQE9MFGv/F0ODIdCO.$aJy0IN9L2kgQiumqRwnXbpwJ9Ktz2YxKOAbYLiJF.A2";
      openssh.authorizedKeys.keys = lib.sshKeys.trusted;
    };
  };

  time.timeZone = "Europe/Berlin";
}
