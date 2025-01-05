{
  inputs,
  lib,
  user,
  ...
}:
{
  imports = lib.mkModulesList ./.;

  profiles = {
    base = {
      enable = true;
      network.tailscale = "server";
    };
    base-devel.enable = true;
  };

  users.users = {
    ${user} = {
      hashedPassword = "$2b$05$V7CpckgiacL3nM/FZ5Fa0OIAZlw469dZswx32kg7lWXRTL8Zme4fa";
      linger = true;
      openssh.authorizedKeys.keys = lib.sshKeys.trusted;
    };
  };

  sops = {
    age.keyFile = "/var/lib/sops-nix/key.txt";
    defaultSopsFile = "${inputs.secrets}/karanohako/secrets.yaml";
  };

  time.timeZone = "Europe/Berlin";
}
