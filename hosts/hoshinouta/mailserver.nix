{ config, ... }:
{
  sops.secrets = {
    "mailserver/users/merrkry/hashed" = { };
    "mailserver/users/mastodon/hashed" = { };
  };

  mailserver = {
    enable = true;
    fqdn = "mail.tsubasa.moe";
    domains = [ "tsubasa.moe" ];

    # mkpasswd -sm bcrypt
    loginAccounts = {
      "merrkry@tsubasa.moe" = {
        hashedPasswordFile = config.sops.secrets."mailserver/users/merrkry/hashed".path;
        aliases = [
          "abuse@tsubasa.moe"
          "admin@tsubasa.moe"
          "postmaster@tsubasa.moe"
          "security@tsubasa.moe"
        ];
      };
      "mastodon@tsubasa.moe" = {
        hashedPasswordFile = config.sops.secrets."mailserver/users/mastodon/hashed".path;
      };
    };

    certificateScheme = "acme-nginx";
  };
}
