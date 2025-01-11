{
  inputs,
  lib,
  user,
  ...
}:
{
  imports = (lib.mkModulesList ./.) ++ [ "${inputs.secrets}/sapphire" ];

  profiles = {
    base = {
      enable = true;
      network.tailscale = "server";
    };
  };

  users.users = {
    ${user} = {
      extraGroups = [ "qbittorrent" ];
      hashedPassword = "$y$j9T$xLHLqiVYRqwaJ7NjWcKgE0$.TGv4WGPvGguZ62GN7coV0xo8l6l4Rm7XDwkyFdoKX6";
      openssh.authorizedKeys.keys = lib.sshKeys.trusted;
    };
  };

  time.timeZone = "Europe/Luxembourg";
}
