{
  pkgs,
  config,
  lib,
  ...
}: {
  imports = [
    ./packages.nix

    ./graphical
    ./terminal
    ./gaming

    ./themes
  ];

  config = {
    home = {
      stateVersion = "23.05";
      extraOutputsToInstall = ["doc" "devdoc"];
    };

    modules = {
      programs = {
        # cozy neovim config with catppuccin colors
        vimuwu.enable = true;

        # schizo firefox config based on firefox ESR
        schizofox = {
          enable = true;
          translate = {
            enable = true;
            sourceLang = "en";
            targetLang = "tr";
          };
        };
      };
    };
  };
}
