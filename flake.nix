{
  description = "Development packages";

  inputs = {
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = inputs @ {
    flake-parts,
    self,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      flake = {
        
        lib = import ./lib {inherit inputs;};

        nixosConfigurations = {
          x86_64 = self.lib.mkNixos {
            hypervisor.sharing.enable = true;
            hypervisor.type = "vmware";
            store.mount.enable = true;
            system = "x86_64-linux";
          };
        };
      };

      systems = ["x86_64-linux"];

      perSystem = {
        inputs',
        pkgs,
        system,
        ...
      }: let
        inherit (pkgs) alejandra callPackage just mkShell;
      in {
        devShells = {
          default = mkShell {
            nativeBuildInputs = [just];
          };
        };

        formatter = alejandra;

        packages = {
          geist-mono = callPackage self.lib.geist-mono {};
        };
      };
    };
}