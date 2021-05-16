{ config, pkgs, ... }:

{
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "aray";
  home.homeDirectory = "/home/aray";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "21.03";

  nixpkgs.config.allowUnfree = true;
  home.packages = [
    pkgs.alacritty
    pkgs.android-studio
    pkgs.anki
    pkgs.cura
    pkgs.discord
    pkgs.firefox
    pkgs.jetbrains.idea-community
    pkgs.jetbrains.pycharm-professional
    pkgs.keepassxc
    pkgs.neomutt
    pkgs.openscad
    pkgs.rust-analyzer
    pkgs.stow
    pkgs.syncthing
  ];

  programs.git = {
    enable = true;
    userName = "Austin Ray";
    userEmail = "austin@austinray.io";
    signing = {
      key = "0127ED83B939CCC98082476E1AA0B115C8AC2C9E";
      signByDefault = true;
    };
  };

  programs.firefox = {
    enable = true;
    profiles.default = {
      userChrome =
      ''
        #TabsToolbar {
          visibility: collapse !important;
        }

        #sidebar-header {
          display: none;
        }
      '';
      userContent = ''
        /* Hide scrollbar in FF Quantum */
        * {scrollbar-width:none !important}
      '';
      settings = {
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
      };
    };
  };

  services.syncthing = {
    enable = true;
  };
}
