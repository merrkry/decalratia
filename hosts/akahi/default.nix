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
    inputs.nixos-hardware.nixosModules.common-gpu-intel

    ./nixos
  ];

  profiles = {
    base.enable = true;
    base-devel.enable = true;
    desktop.enable = true;
    cli = {
      helix.enable = true;
      lunarvim.enable = true;
    };
    gui = {
      vscode.enable = true;
      zed.enable = true;
    };
  };

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

  home-manager.users."merrkry" = {
    imports = [ ./home-manager ];
  };

  sops.age.keyFile = "/var/lib/sops-nix/key.txt";

  # to prevent /srv subvolume from being created
  environment.etc."tmpfiles.d/home.conf".text = ''
    Q /home 0755 - - -
    # q /srv 0755 - - -
  '';

  system.etc.overlay.enable = false;
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

  time.timeZone = "Europe/Berlin";
}
