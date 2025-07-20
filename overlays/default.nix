{ helpers, inputs, ... }:
{
  extraPackages = final: prev: import ../pkgs final.pkgs;

  modifications =
    final: prev:
    import ./modifications.nix {
      inherit helpers;
      pkgs = prev;
    };

  stablePackages = final: prev: {
    stable = import inputs.nixpkgs-stable { inherit (final) config system; };
  };
}
