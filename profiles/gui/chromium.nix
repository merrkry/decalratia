{
  config,
  helpers,
  lib,
  pkgs,
  user,
  ...
}:
let
  cfg = config.profiles.gui.chromium;
  googleSearchOpts = {
    DefaultSearchProviderKeyword = "google.com";
    DefaultSearchProviderName = "Google";
    DefaultSearchProviderSearchURL = "https://www.google.com/search?q={searchTerms}&{google:RLZ}{google:originalQueryForSuggestion}{google:assistedQueryStats}{google:searchFieldtrialParameter}{google:searchClient}{google:sourceId}ie={inputEncoding}";
    DefaultSearchProviderSuggestURL = "https://www.google.com/complete/search?output=chrome&q={searchTerms}";
  };
  kagiSearchOpts = {
    DefaultSearchProviderKeyword = "kagi.com";
    DefaultSearchProviderName = "Kagi";
    DefaultSearchProviderSearchURL = "https://kagi.com/search?q=%s";
  };
in
{
  options.profiles.gui.chromium = {
    enable = lib.mkEnableOption "chromium";
  };

  config = lib.mkIf cfg.enable {
    programs.chromium = {
      # https://chromeenterprise.google/intl/en_us/policies/
      extraOpts = {
        DefaultSearchProviderEnabled = true;

        DnsOverHttpsMode = "automatic";
        DnsOverHttpsTemplates = "https://1.1.1.1/dns-query{?dns}";
      }
      // kagiSearchOpts;
    };

    home-manager.users.${user} = {
      programs.chromium = {
        enable = true;
        package = pkgs.ungoogled-chromium.override { enableWideVine = true; };
        commandLineArgs = helpers.chromiumArgs ++ [
          "--password-store=gnome-libsecret"
          "--enable-features=AcceleratedVideoDecodeLinuxGL"
        ];
        # doesn't work for ungoogled-chromium, https://github.com/nix-community/home-manager/pull/4174
        # extensions = [
        #   {
        #     id = "ocaahdebbfolfmndjeplogmgcagdmblk";
        #     updateUrl = "https://raw.githubusercontent.com/NeverDecaf/chromium-web-store/refs/heads/master/updates.xml";
        #   }
        # ];
      };
    };
  };
}
