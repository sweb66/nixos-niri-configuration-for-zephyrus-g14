{
  description = "ASUS Zephyrus G14 GA401IU + Niri";

  inputs = {
    # Основной репозиторий NixOS 25.11
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    
    # Профили железа
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    # Niri compositor
    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Home Manager для пользовательских настроек
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixos-hardware, niri, home-manager, ... }@inputs:
  let
    system = "x86_64-linux";
    user = "user"; # ПОМЕНЯЙ НА СВОЁ ИМЯ ПОЛЬЗОВАТЕЛЯ
  in
  {
    nixosConfigurations.g14 = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs user; };
      modules = [
        # Профиль железа для твоей модели
        nixos-hardware.nixosModules.asus-zephyrus-ga401
        
        # Niri из флейка
        niri.nixosModules.niri
        
        # Home Manager
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.${user} = import ./home.nix;
          home-manager.extraSpecialArgs = { inherit inputs user; };
        }
        
        # Основная конфигурация системы
        ./configuration.nix
      ];
    };
  };
}