{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.presets.base;
in
{
  options.presets.base = {
    enable = lib.mkEnableOption "base" // {
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {

    nix = {
      package = pkgs.nixVersions.latest;
      settings = {
        download-buffer-size = 268435456;
        experimental-features = [
          "nix-command"
          "flakes"
          "ca-derivations"
          "auto-allocate-uids"
          "cgroups"
        ];
        auto-allocate-uids = true;
        use-cgroups = true;
        auto-optimise-store = true;
        use-xdg-base-directories = true;
        trusted-users = [
          "root"
          # dangerous, see https://github.com/NixOS/nix/issues/9649#issuecomment-1868001568
          # "@wheel"
        ];
        substituters = [
          "https://nix-community.cachix.org"
          "https://cache.garnix.io"
        ];
        trusted-public-keys = [
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
        ];
      };
      channel.enable = false;
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 7d";
      };
    };

    systemd.services.nix-gc.serviceConfig = {
      Nice = 19;
      IOSchedulingClass = "idle";
      MemorySwapMax = 0;
    };

    nixpkgs = {
      config.allowUnfree = true;
    };

    systemd.user.extraConfig = ''
      DefaultLimitNOFILE=524288
    '';

    users.mutableUsers = false;

    services.timesyncd.enable = false;
    services.chrony = {
      enable = true;
      enableNTS = true;
      servers = [ "time.cloudflare.com" ];
    };

    boot.initrd.systemd.enable = true;

    documentation.nixos.enable = false;
    # introduced by fish, making rebuild extremely slow
    documentation.man.generateCaches = lib.mkForce false;

    security.pam.sshAgentAuth.enable = true;
    security.pam.services.sudo.sshAgentAuth = true;
    services.openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
      };
    };

    networking.firewall.enable = true;
    services.fail2ban.enable = true;

    services.bpftune.enable = true;
    boot.kernel.sysctl = {
      "net.core.default_qdisc" = "fq";
      "net.ipv4.tcp_congestion" = "bbr";
      "net.ipv4.tcp_slow_start_after_idle" = 0;
      "net.ipv4.tcp_notsent_lowat" = 16384;
    };

    environment.sessionVariables = {
      HOSTNAME = config.networking.hostName;
      EDITOR = lib.mkDefault "micro";
    };

    environment.systemPackages = with pkgs; [
      wget
      curl

      neovim
      micro

      git

      rsync
    ];

  };

}
