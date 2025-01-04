{
  desktop,
  hypervisor,
  inputs,
  store,
  username,
}: {pkgs, ...}: {
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = true;
    };
  };

  fileSystems =
    {}
    // pkgs.lib.optionalAttrs hypervisor.sharing.enable {
      "/mnt/hgfs" = {
        device = ".host:/";
        fsType = "fuse./run/current-system/sw/bin/vmhgfs-fuse";
        options = [
          "allow_other"
          "auto_unmount"
          "defaults"
          "gid=1000"
          "uid=1000"
          "umask=22"
        ];
      };
    }
    // pkgs.lib.optionalAttrs store.mount.enable {
      "/nix" = {
        device = "/dev/disk/by-label/nix";
        fsType = "ext4";
        neededForBoot = true;
        options = ["noatime"];
      };
    };

  environment = {
    pathsToLink = ["/libexec" "/share/zsh"];
    systemPackages = with pkgs;
      [
        curl
        vim
        wget
        xclip
      ]
      ++ pkgs.lib.optionals desktop [
        dunst
        libnotify
        lxappearance
        pavucontrol
      ];
  };

  i18n.defaultLocale = "en_US.UTF-8";

  networking = {
    firewall.enable = false;
    hostName = "${username}-nixos";
    networkmanager.enable = true;
  };

  nix = import ../shared/nix.nix;

  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };

  programs.zsh.enable = true;

  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

  services = {
    dbus = {
      packages = [pkgs.gcr];
    };

    logind.extraConfig = ''
      RuntimeDirectorySize=20G
    '';

    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "no";
      };
    };
  };

  system.stateVersion = "23.05";

  time.timeZone = "America/Los_Angeles";

  users = {
    mutableUsers = false;
    users."${username}" = {
      extraGroups = ["docker" "wheel"] ++ pkgs.lib.optionals desktop ["audio"];
      hashedPassword = "";
      home = "/home/${username}";
      isNormalUser = true;
      shell = pkgs.zsh;
    };
  };

  virtualisation = {
    docker = {
      daemon = {
        settings = {
          "experimental" = true;
          "features" = {
            "containerd-snapshotter" = true;
          };
        };
      };
      enable = true;
    };

    vmware.guest.enable =
      if hypervisor.type == "vmware"
      then true
      else false;
  };
}