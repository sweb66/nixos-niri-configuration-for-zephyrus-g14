{
  description = "ASUS Zephyrus G14 GA401IU + Niri";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixos-hardware, home-manager, ... }@inputs:
  let
    system = "x86_64-linux";
    user = "sweb";
  in
  {
    nixosConfigurations.g14 = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs user; };
      modules = [
        {
          nixpkgs.config.allowUnfree = true;
        }
        
        nixos-hardware.nixosModules.asus-zephyrus-ga401
        
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.${user} = import ./home.nix;
          home-manager.extraSpecialArgs = { inherit inputs user; };
        }
        
        ./configuration.nix
      ];
    };
  };
}