{ helpers, ... }:
{
  # Causes infinite recursion, weired.
  # Guess it's something related to home-manager's module implementation
  # imports = helpers.mkModulesList ./.;
  imports = [
    ./fakehome.nix
    ./swaybg.nix
  ];
}
