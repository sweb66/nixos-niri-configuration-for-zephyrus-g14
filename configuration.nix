{ config, lib, pkgs, inputs, user, ... }:

{
  nixpkgs.config.allowUnfree = true;

  # ==================== ЯДРО И ЗАГРУЗКА ====================
  boot.kernelPackages = pkgs.linuxPackages_7_0;
  
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  # ==================== ФАЙЛОВЫЕ СИСТЕМЫ ====================
  # !!! ЗАМЕНИ UUID НА СВОИ (команда: lsblk -f) !!!
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/ЗАМЕНИ_НА_UUID_КОРНЕВОГО_РАЗДЕЛА";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/ЗАМЕНИ_НА_UUID_BOOT_РАЗДЕЛА";
    fsType = "vfat";
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/ЗАМЕНИ_НА_UUID_SWAP"; }
  ];

  # ==================== ЛОКАЛИЗАЦИЯ ====================
  time.timeZone = "Europe/Moscow";
  i18n.defaultLocale = "ru_RU.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "ru";
  };

  # ==================== СЕТЬ ====================
  networking.networkmanager.enable = true;
  networking.hostName = "g14";

  # ==================== ПОЛЬЗОВАТЕЛЬ ====================
  users.users.${user} = {
    isNormalUser = true;
    initialPassword = "changeme";
    extraGroups = [
      "wheel"
      "video"
      "audio"
      "disk"
      "networkmanager"
      "power"
    ];
  };

  users.users.root.initialPassword = "rootchangeme";
  security.sudo.enable = true;

  # ==================== ГРАФИКА ====================
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # ==================== WAYLAND ====================
  services.xserver.enable = false;

  # ==================== NIRI ====================
  programs.niri.enable = true;
  programs.niri.package = pkgs.niri;

  # ==================== ОХЛАЖДЕНИЕ ====================
  services.asusd = {
    enable = true;
    enableUserService = true;
  };

  services.supergfxd.enable = true;
  services.power-profiles-daemon.enable = true;

  # Отключаем проблемный сервис nvidia-powerd
  systemd.services.nvidia-powerd.enable = false;

  # ==================== ЗВУК ====================
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  # ==================== PORTAL ====================
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gnome
      xdg-desktop-portal-gtk
    ];
    config.common.default = "*";
  };

  # ==================== ШРИФТЫ ====================
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-color-emoji
    noto-fonts-cjk-sans
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
  ];

  # ==================== СИСТЕМНЫЕ ПАКЕТЫ ====================
  environment.systemPackages = with pkgs; [
    wayland-utils
    wlr-randr
    wl-clipboard
    wl-screenrec
    grim
    slurp
    kitty
    fuzzel
    mako
    waybar
    pciutils
    usbutils
    mesa-demos
    vulkan-tools
    asusctl
    unzip
    unrar
    networkmanager
  ];

  # ==================== STEAM ====================
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
    extraCompatPackages = with pkgs; [
      proton-ge-bin
    ];
  };

  programs.gamemode = {
    enable = true;
    settings = {
      general = {
        desiredgov = "performance";
        softrealtime = "auto";
        renice = 10;
      };
    };
  };

  # ==================== ОПТИМИЗАЦИЯ ====================
  nix.settings.auto-optimise-store = true;
  
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  system.stateVersion = "25.11";
}