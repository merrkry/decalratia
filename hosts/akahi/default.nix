{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}:
{
  imports = [
    outputs.nixosModules.base
    outputs.nixosModules.base-devel
    outputs.nixosModules.desktop

    inputs.home-manager-unstable.nixosModules.home-manager
    inputs.nixos-hardware.nixosModules.common-gpu-intel
    inputs.sops-nix.nixosModules.sops
    inputs.niri-flake.nixosModules.niri
    inputs.stylix.nixosModules.stylix
    inputs.chaotic.nixosModules.default

    ./nixos
  ];

  nixpkgs.overlays = [ inputs.nur.overlays.default ];

  users.users = {
    "merrkry" = {
      hashedPassword = "$y$j9T$0RaEe1vqgRkZZPv9t9p6b0$RgZyFgbLwUkFwT7TmLcvn5aTfix7.K3x/hz/FPQP71D";
      isNormalUser = true;
      openssh.authorizedKeys.keys = [ ];
      extraGroups = [
        "wheel"
        "libvirtd"
        "kvm"
      ];
    };
  };

  home-manager = {
    extraSpecialArgs = { inherit inputs outputs; };
    users."merrkry" = {
      imports = [
        ./home-manager
        outputs.homeManagerModules.base
        outputs.homeManagerModules.base-devel
        outputs.homeManagerModules.desktop
      ];
    };
    useUserPackages = true;
    useGlobalPkgs = true;
    backupFileExtension = "backup";
  };

  sops.age.keyFile = "/var/lib/sops-nix/key.txt";

  # to prevent /srv subvolume from being created
  environment.etc."tmpfiles.d/home.conf".text = ''
    Q /home 0755 - - -
    # q /srv 0755 - - -
  '';

  system.etc.overlay.enable = true;
  services.openssh.hostKeys = lib.mkForce [
    {
      bits = 4096;
      path = "/var/lib/ssh/ssh_host_rsa_key";
      type = "rsa";
    }
    {
      path = "/var/lib/ssh/ssh_host_ed25519_key";
      type = "ed25519";
    }
  ];

  programs.nix-ld = {
    enable = true;
    libraries =
      (pkgs.appimageTools.defaultFhsEnvArgs.targetPkgs pkgs)
      ++ (pkgs.appimageTools.defaultFhsEnvArgs.multiPkgs pkgs)
      ++ (with pkgs; [ webkitgtk_6_0 ]);
  };

  time.timeZone = "Europe/Berlin";
}
