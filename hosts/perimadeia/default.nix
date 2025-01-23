{ inputs, lib, ... }:
{
  imports = (lib.mkModulesList ./.) ++ [ "${inputs.secrets}/perimadeia" ];

  profiles = {
    base = {
      enable = true;
      network.tailscale = "server";
    };
    base-devel.enable = true;
  };

  users.users = {
    "merrkry" = {
      hashedPassword = "$y$j9T$Sgcp0Wdv00yqYcNv2QYeZ0$AsMUpgwygZW1UXDgmIcpi.QrbFVkBpdG25c5xTQckI2";
      isNormalUser = true;
      openssh.authorizedKeys.keys = lib.sshKeys.trusted;
      extraGroups = [ "wheel" ];
      linger = true;
    };
  };

  time.timeZone = "Europe/Berlin";
}
