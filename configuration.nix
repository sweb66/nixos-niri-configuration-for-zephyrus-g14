{ config, lib, pkgs, inputs, user, ... }:

{
  # ==================== ЯДРО И ЗАГРУЗКА ====================
  boot.kernelPackages = pkgs.linuxPackages_7_0;
  
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };


 # ==================== ФАЙЛОВЫЕ СИСТЕМЫ ====================
  # !! ВАЖНО: замени UUID на свои !!
  # Узнай свои UUID командой: lsblk -f
  
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/ЗАМЕНИ_НА_UUID_КОРНЕВОГО_РАЗДЕЛА";
    fsType = "ext4"; # или btrfs, xfs - что использовал при установке
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/ЗАМЕНИ_НА_UUID_BOOT_РАЗДЕЛА";
    fsType = "vfat";
  };

  # Если есть swap раздел
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
    initialPassword = "changeme"; # СМЕНИ ПРИ ПЕРВОМ ВХОДЕ
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
  # Просто включаем, без settings
  programs.niri.enable = true;

  # Конфигурация niri через отдельный файл
  environment.etc."niri/config.kdl" = {
    text = ''
      // Конфигурация niri для G14
      
      // Встроенный экран 120 Гц
      output "eDP-1" {
          mode 1920x1080@120
          scale 1.0
      }
      
      // Таймаут бездействия (5 минут)
      idle-timeout-sec 300
      
      // Горячие клавиши
      binds {
          // Запуск приложений
          Mod+T { spawn "kitty"; }
          Mod+D { spawn "fuzzel"; }
          Mod+B { spawn "firefox"; }
          
          // Закрыть окно
          Mod+Q { close; }
          
          // Полный экран
          Mod+F { fullscreen; }
          
          // Выход
          Mod+Shift+E { quit; }
          
          // Переключение между окнами
          Mod+H { focus-column-left; }
          Mod+L { focus-column-right; }
          Mod+J { focus-window-down; }
          Mod+K { focus-window-up; }
          
          // Перемещение окон
          Mod+Ctrl+H { move-column-left; }
          Mod+Ctrl+L { move-column-right; }
          Mod+Ctrl+J { move-window-down; }
          Mod+Ctrl+K { move-window-up; }
          
          // Изменение размера
          Mod+R { switch-preset-column-width; }
          Mod+Shift+R { reset-window-height; }
          
          // Рабочие столы
          Mod+1 { focus-workspace 1; }
          Mod+2 { focus-workspace 2; }
          Mod+3 { focus-workspace 3; }
          Mod+4 { focus-workspace 4; }
          Mod+Shift+1 { move-window-to-workspace 1; }
          Mod+Shift+2 { move-window-to-workspace 2; }
          Mod+Shift+3 { move-window-to-workspace 3; }
          Mod+Shift+4 { move-window-to-workspace 4; }
      }
      
      // Правила для окон
      window-rules {
          match app-id="steam" {
              open-floating true
          }
          
          match app-id=".*" title="Steam Settings" {
              open-floating true
          }
      }
      
      // Оформление
      layout {
          gaps 4
          preset-column-widths {
              proportion 0.5
              proportion 0.6
              proportion 0.7
          }
          default-column-width { proportion 0.5; }
      }
    '';
    mode = "0644";
  };

  # Создаём директорию для конфига
  system.activationScripts.niriConfigDir = ''
    mkdir -p /home/${user}/.config/niri
    cp ${config.environment.etc."niri/config.kdl".source} /home/${user}/.config/niri/config.kdl
    chown -R ${user}:users /home/${user}/.config/niri
  '';

  # ==================== ОХЛАЖДЕНИЕ ====================
  services.asusd = {
    enable = true;
    enableUserService = true;
  };

  services.supergfxd.enable = true;
  services.power-profiles-daemon.enable = true;

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
    noto-fonts-emoji
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
    glxinfo
    vulkan-tools
    asusctl
    unzip
    unrar
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