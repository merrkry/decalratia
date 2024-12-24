{ ... }:
{
  mailserver = {
    enable = true;
    fqdn = "mail.tsubasa.moe";
    domains = [ "tsubasa.moe" ];

    # mkpasswd -sm bcrypt
    loginAccounts = {
      "merrkry@tsubasa.moe" = {
        hashedPassword = "$2b$05$w7dW24iaph5PvpNgIG0tI.5G/5hqscPILrQIp.OvFgJfGi1pEMJDG";
        aliases = [ "postmaster@tsubasa.moe" ];
      };
      "mastodon@tsubasa.moe" = {
        hashedPassword = "$2b$05$VI0eltHq8l6dOSCJt2QQP.eRa2o8VXSlsAOIqFYm0InKwUz/lHGn6";
      };
    };

    certificateScheme = "acme-nginx";
  };
}
