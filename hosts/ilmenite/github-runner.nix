{ config, pkgs, ... }:
{
  services.github-runners."ilmenite" = {
    enable = true;
    extraPackages = with pkgs; [
      attic-client
      nix-fast-build
      nvfetcher
    ];
    replace = true;
    tokenFile = config.sops.secrets."github-runner/pat".path;
    url = "https://github.com/merrkry/declaratia";
  };

  sops.secrets."github-runner/pat" = { };
}
