{ inputs, ... }:
{
  extraLibs = final: prev: import ../libs { lib = final; };
  extraPackages = final: prev: import ../pkgs final.pkgs;

  modifications = final: prev: import ./modifications.nix { pkgs = prev; };

  # unstablePackages = final: prev: {
  #   unstable = import inputs.nixpkgs-unstable {
  #     system = final.system;
  #     inherit (final) config;
  #   };
  # };

  stablePackages = final: prev: {
    stable = import inputs.nixpkgs-stable {
      system = final.system;
      inherit (final) config;
    };
  };
}
