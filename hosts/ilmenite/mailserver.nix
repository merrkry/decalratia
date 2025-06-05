{ config, ... }:
{
  sops.secrets = {
    "mailserver/hashedPasswd/merrkry" = { };
    "mailserver/hashedPasswd/mastodon" = { };
  };

  mailserver = {
    enable = true;
    fqdn = "mail.tsubasa.moe";
    domains = [ "tsubasa.moe" ];

    loginAccounts = {
      "merrkry@tsubasa.moe" = {
        hashedPasswordFile = config.sops.secrets."mailserver/hashedPasswd/merrkry".path;
        aliases = [
          "abuse@tsubasa.moe"
          "admin@tsubasa.moe"
          "postmaster@tsubasa.moe"
          "security@tsubasa.moe"
        ];
      };
      "mastodon@tsubasa.moe" = {
        hashedPasswordFile = config.sops.secrets."mailserver/hashedPasswd/mastodon".path;
      };
    };

    certificateScheme = "acme";
    acmeCertificateName = "ilmenite.tsubasa.moe";

    stateVersion = 1;
  };
}
