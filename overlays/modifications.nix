{ pkgs, ... }:
{
  mautrix-telegram = pkgs.mautrix-telegram.overrideAttrs (
    finalAttrs: oldAttrs: {
      src = pkgs.fetchFromGitHub {
        owner = "mautrix";
        repo = "telegram";
        rev = "6480e7925e3353200b894ddc86e2880409b01ba3";
        hash = "sha256-P9/rgq7cHZXQ6doP4aiWAQYwoNxkg5VyAC5kFnZbNPM=";
      };
    }
  );

  # Allow to keep the same name between updates
  # https://github.com/chaotic-cx/nyx/blob/main/pkgs/proton-ge-custom/default.nix
  # https://github.com/NixOS/nixpkgs/blob/master/pkgs/by-name/pr/proton-ge-bin/package.nix
  proton-ge-bin = pkgs.proton-ge-bin.overrideAttrs (
    finalAttrs: oldAttrs: {
      # fetchzip handles unpacking on its own, instead of unpackPhase
      # might be better to use fetchurl and extract in buildCommand to reduce i/o consumption
      # but will hash change?
      buildCommand = ''
        # Make it impossible to add to an environment. You should use the appropriate NixOS option.
        # Also leave some breadcrumbs in the file.
        echo "${finalAttrs.pname} should not be installed into environments. Please use programs.steam.extraCompatPackages instead." > $out

        cp -r $src/ $steamcompattool
        substituteInPlace $steamcompattool/compatibilitytool.vdf --replace-fail "${oldAttrs.version}" "Proton-GE"
      '';
    }
  );
}
