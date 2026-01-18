{
  config,
  lib,
  user,
  ...
}:
let
  cfg = config.profiles.desktop.security;
in
{
  options.profiles.desktop.security = {
    enable = lib.mkEnableOption "security";
  };

  config = lib.mkIf cfg.enable {
    security = {
      pam.services.swaylock = { };
      polkit.enable = true;
    };

    services = {
      gnome.gnome-keyring.enable = true;

      # https://docs.canokeys.org/zh-hans/userguide/setup/
      udev.extraRules = ''
        # GnuPG/pcsclite
        SUBSYSTEM!="usb", GOTO="canokeys_rules_end"
        ACTION!="add|change", GOTO="canokeys_rules_end"
        ATTRS{idVendor}=="20a0", ATTRS{idProduct}=="42d4", ENV{ID_SMARTCARD_READER}="1"
        LABEL="canokeys_rules_end"

        # FIDO2
        # note that if you find this line in 70-fido.rules, you can ignore it
        KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="20a0", ATTRS{idProduct}=="42d4", TAG+="uaccess"
        # make this usb device accessible for users, used in WebUSB
        # change the mode so unprivileged users can access it, insecure rule, though
        SUBSYSTEMS=="usb", ATTR{idVendor}=="20a0", ATTR{idProduct}=="42d4", MODE:="0666"
        # if the above works for WebUSB (web console), you may change into a more secure way
        # choose one of the following rules
        # note if you use "plugdev", make sure you have this group and the wanted user is in that group
        #SUBSYSTEMS=="usb", ATTR{idVendor}=="20a0", ATTR{idProduct}=="42d4", TAG+="uaccess"
      '';
    };

    home-manager.users.${user} = {
      services = {
        # executes the same binary as nixos module, might be conflicting
        gnome-keyring.enable = lib.mkDefault (!config.services.gnome.gnome-keyring.enable);
        # Not working very well with "cannot open display:" returned. Perhaps because of env vars, use
        # `sudo -E` instead for now.
        polkit-gnome.enable = true;
      };

      systemd.user.services."polkit-gnome".Unit.After = [ "graphical-session.target" ];
    };
  };
}
