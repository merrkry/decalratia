{ pkgs, ... }:
{

  linuxPackages_zen = pkgs.linuxPackagesFor (
    pkgs.linuxKernel.kernels.linux_zen.override {
      argsOverride =
        let
          nvfetcher = (builtins.fromJSON (builtins.readFile ../versions/generated.json)).linux-zen;
          versions = builtins.match "^v?([0-9]+\.[0-9]+\.[0-9]+|[0-9]+\.[0-9]+)-zen?([0-9]+)$" nvfetcher.version;
          kernelVer = builtins.elemAt versions 0;
          patchVer = builtins.elemAt versions 1;
        in
        rec {
          version = kernelVer;
          modDirVersion =
            if (builtins.match "^[0-9]+\.[0-9]+$" version != null) then
              "${version}.0-zen${patchVer}"
            else
              "${version}-zen${patchVer}";
          src = pkgs.fetchFromGitHub {
            owner = "zen-kernel";
            repo = "zen-kernel";
            rev = "v${version}-zen${patchVer}";
            hash = nvfetcher.src.sha256;
          };
        };
    }
  );

  looking-glass-client-git = pkgs.looking-glass-client.overrideAttrs (
    finalAttrs: oldAttrs: {
      src = pkgs.fetchFromGitHub {
        owner = "gnif";
        repo = "LookingGlass";
        rev = "e25492a3a36f7e1fde6e3c3014620525a712a64a";
        hash = "sha256-DBmCJRlB7KzbWXZqKA0X4VTpe+DhhYG5uoxsblPXVzg=";
        fetchSubmodules = true;
      };
      nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [ pkgs.nanosvg ];
      patches = [ ./nanosvg-unvendor.diff ];
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
