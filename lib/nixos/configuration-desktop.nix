{
  geist-mono,
  hypervisor,
  username,
}: {
  lib,
  pkgs,
  ...
}: {
  fonts = {
    fontconfig = {
      defaultFonts.monospace = ["GeistMono NFM"];
      enable = true;
    };

    packages = [geist-mono];
  };

  hardware = {
    graphics.enable = true;
  };

  programs = {
    dconf.enable = true;
    geary.enable = true;
  };

  services = {
    displayManager = {
      autoLogin = {
        enable = true;
        user = username;
      };
      defaultSession = "none+i3";
    };

    picom.enable = true;

    xserver = {
      enable = true;

      desktopManager = {
        xterm.enable = false;
        wallpaper.mode = "fill";
      };

      displayManager.lightdm.enable = true;

      windowManager.i3 = {
        enable = true;
        package = pkgs.i3-gaps;
        extraPackages = with pkgs; [i3status i3lock i3blocks];
      };

      xkb.layout = "us";
    };
  };
}