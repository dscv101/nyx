{
  config,
  lib,
  pkgs,
  ...
}:
with lib; {
  imports = [
    ./boot.nix
    ./iso.nix
    ./network.nix
  ];

  # FIXME: for some reason, we cannot boot off ventoy
  # and have to burn the iso to an entire USB with dd
  # dd if=result/iso/*.iso of=/dev/sdX status=progress

  # system packages for the base installer
  environment.systemPackages = with pkgs; [git neovim netcat];
  users.extraUsers.root.password = "";

  # console locale #
  console = let
    variant = "u24n";
  in {
    # hidpi terminal font
    font = "${pkgs.terminus_font}/share/consolefonts/ter-${variant}.psf.gz";
    keyMap = "trq";
  };

  # attempt to fix "too many open files"
  security.pam.loginLimits = [
    {
      domain = "*";
      item = "nofile";
      type = "-";
      value = "65536";
    }
  ];

  services.getty.helpLine =
    ''
      The "nixos" and "root" accounts have empty passwords.
      An ssh daemon is running. You then must set a password
      for either "root" or "nixos" with `passwd` or add an ssh key
      to /home/nixos/.ssh/authorized_keys be able to login.
      If you need a wireless connection, you may use networkmanager
      by invoking `nmcli` or `nmtui`, the ncurses interface.
    ''
    + optionalString config.services.xserver.enable ''
      Type `sudo systemctl start display-manager' to
      start the graphical user interface.
    '';

  # borrow some environment options from the minimal profile to save space
  environment.noXlibs = mkDefault true; # trim inputs

  # disable documentation
  documentation = {
    enable = mkDefault false;

    doc.enable = mkDefault false;

    info.enable = mkDefault false;
  };
}
