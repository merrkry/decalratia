{ inputs, ... }:
{
  additions = final: _prev: import ../pkgs final.pkgs;

  modifications = final: prev: {

    # Allow to keep the same name between updates
    # https://github.com/chaotic-cx/nyx/blob/main/pkgs/proton-ge-custom/default.nix
    # https://github.com/NixOS/nixpkgs/blob/master/pkgs/by-name/pr/proton-ge-bin/package.nix
    proton-ge-bin = prev.proton-ge-bin.overrideAttrs (
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

    # https://gitlab.com/asus-linux/asusctl/-/issues/550
    # https://discourse.nixos.org/t/is-it-possible-to-override-cargosha256-in-buildrustpackage/4393/4
    asusctl = prev.callPackage prev.asusctl.override {
      rustPlatform = prev.rustPlatform // {
        buildRustPackage =
          args:
          prev.rustPlatform.buildRustPackage (
            args
            // {
              src = prev.fetchFromGitLab {
                owner = "asus-linux";
                repo = "asusctl";
                rev = "e7c4619ee9bc241d155b2f948aaa3968c515c217";
                hash = "sha256-U2e7Qw+X56P1yjtvM4JPxd8t8a4S2pB0aUPO9W8CZb0=";
              };
              cargoLock = null;
              useFetchCargoVendor = true;
              cargoHash = "sha256-khb3QpRz0tTD+ISx8P8yeLPyyO+av2yV92ZxTc9o5kw=";
            }
          );
      };
    };

    # Directly overriding looking-glass-git will cause the deriviation of kvmfr module to be changed.
    # This will require the patches in kvmfr also be removed.
    # As the kernel modules are a bit tricky to overlay, generating a new package seems to be the best option.
    looking-glass-client-git = prev.looking-glass-client.overrideAttrs (
      finalAttrs: oldAttrs: {
        src = prev.fetchFromGitHub {
          owner = "gnif";
          repo = "LookingGlass";
          rev = "e25492a3a36f7e1fde6e3c3014620525a712a64a";
          hash = "sha256-DBmCJRlB7KzbWXZqKA0X4VTpe+DhhYG5uoxsblPXVzg=";
          fetchSubmodules = true;
        };
        patches = [ ];
      }
    );

  };

  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      system = final.system;
      config.allowUnfree = true;
    };
  };

  stable-packages = final: _prev: {
    stable = import inputs.nixpkgs-stable {
      system = final.system;
      config.allowUnfree = true;
    };
  };
}
