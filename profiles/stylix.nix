{ pkgs, user, ... }:
{
  stylix = {
    # Stylix only imports hm module when enabled, resulting in eval failure in this config
    enable = true;

    # Extremely invasive
    autoEnable = false;

    enableReleaseChecks = false;

    base16Scheme = "${pkgs.base16-schemes}/share/themes/espresso.yaml";
  };

  home-manager.users.${user} = {
    stylix.enableReleaseChecks = false;
  };
}
