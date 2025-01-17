{ config, ... }:
{
  services.github-runners."declaratia" = {
    enable = true;
    ephemeral = true;
    replace = true;
    tokenFile = config.sops.secrets."github-runner/pat".path;
    url = "https://github.com/merrkry/declaratia";
  };

  sops.secrets."github-runner/pat" = { };
}
