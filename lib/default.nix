{inputs}: let
  defaultGit = {
    extraConfig.github.user = defaultUsername;
    userEmail = "25242236+justinpaulosolo@users.noreply.github.com";
    userName = "Justin Solo";
  };

  defaultStore = {
    mount.enable = false;
  };

  defaultHypervisor = {
    sharing.enable = false;
    type = "vmware";
  };

  defaultUsername = "justinsolo1";

  homeManagerShared = import ./shared/home-manager.nix {inherit inputs;};
in {
  geist-mono = {
    fetchzip,
    lib,
    stdenvNoCC,
  }:
    stdenvNoCC.mkDerivation rec {
      pname = "geist-mono";
      version = "3.3.0";

      src = fetchzip {
        hash = "sha256-4El6oqFDs3jYLbyQfFgDvGz9oP2s3hZ/hZO13Afah0g=";
        stripRoot = false;
        url = "https://github.com/ryanoasis/nerd-fonts/releases/download/v${version}/GeistMono.zip";
      };

      postInstall = ''
        install -Dm444 *.otf -t $out/share/fonts
      '';
    };

  mkNixos = {
    desktop ? true,
    git ? defaultGit,
    hypervisor ? defaultHypervisor,
    store ? defaultStore,
    system,
    username ? defaultUsername,
  }: let
    geist-mono = inputs.self.packages.${system}.geist-mono;
  in
    inputs.nixpkgs.lib.nixosSystem {
      inherit system;
      modules =
        [
          (import ./nixos/hardware/${hypervisor.type}/${system}.nix)
          (import ./nixos/configuration.nix {inherit hypervisor inputs desktop store username;})

          inputs.home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users."${username}" = {pkgs, ...}: {
              imports =
                [
                  (import ./nixos/home-manager.nix)
                  (homeManagerShared {inherit git;})
                ]
                ++ (
                  if desktop
                  then [
                    (import ./nixos/home-manager-desktop.nix {inherit geist-mono;})
                  ]
                  else []
                );
            };
          }
        ]
        ++ inputs.nixpkgs.lib.optionals desktop [
          (import
            ./nixos/configuration-desktop.nix
            {
              inherit geist-mono hypervisor username;
            })
        ];
    };
}