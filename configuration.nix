{ config, lib, pkgs, inputs, user, ... }:

{
  # ==================== ЯДРО И ЗАГРУЗКА ====================
  # Ядро Linux 7.0
  boot.kernelPackages = pkgs.linuxPackages_7_0;
  
  # Поддержка systemd-boot (надёжнее для UEFI)
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  # ==================== ЛОКАЛИЗАЦИЯ ====================
  time.timeZone = "Europe/Moscow"; # Поправь под себя
  i18n.defaultLocale = "ru_RU.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "ru"; # Русская раскладка в консоли
  };

  # ==================== СЕТЬ ====================
  networking.networkmanager.enable = true;
  networking.hostName = "g14";

  # ==================== ПОЛЬЗОВАТЕЛЬ ====================
  users.users.${user} = {
    isNormalUser = true;
    initialPassword = "changeme"; # СМЕНИ ПРИ ПЕРВОМ ВХОДЕ
    extraGroups = [
      "wheel"       # sudo
      "video"       # Доступ к ускорению графики
      "audio"       # Звук
      "disk"        # Доступ к дискам
      "networkmanager"
      "power"       # Управление питанием
    ];
  };

  # Пароль для root
  users.users.root.initialPassword = "rootchangeme"; # СМЕНИ

  # Разрешаем sudo с паролем
  security.sudo.enable = true;

  # ==================== ГРАФИКА (БАЗА) ====================
  # Профиль nixos-hardware уже настраивает драйвера Nvidia и AMD,
  # настраивает Prime с правильными BusId, включает modesetting.
  # Нам остаётся только общая поддержка OpenGL.
  
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # Обязательно для Steam и Proton
  };

  # ==================== WAYLAND ====================
  # X-сервер полностью отключён
  services.xserver.enable = false;

  # ==================== NIRI ====================
  # Включаем niri как основной композитор
  programs.niri = {
    enable = true;
    # Базовая конфигурация niri
    settings = {
      # Выход на встроенный экран
      outputs."eDP-1" = {
        mode.width = 1920;
        mode.height = 1080;
        mode.refresh = 120.0; # У G14 экран 120 Гц
        scale = 1.0;
      };
      
      # Отключаем экран при бездействии
      idle-timeout-sec = 300;
      
      # Привязки клавиш
      binds = {
        # Закрыть окно
        "Mod+Q".action.close = {};
        # Запуск терминала
        "Mod+T".action.spawn = "kitty";
        # Запуск лаунчера
        "Mod+D".action.spawn = "fuzzel";
        # Полноэкранный режим
        "Mod+F".action.fullscreen = {};
        # Выход из niri
        "Mod+Shift+E".action.quit = {};
      };
      
      # Правила для окон
      window-rules = [
        {
          # Окна Steam сделать плавающими
          matches = [ { app-id = "steam"; } ];
          default-column-width = {};
          open-floating = true;
        }
      ];
    };
  };

  # ==================== ОХЛАЖДЕНИЕ И УПРАВЛЕНИЕ ПИТАНИЕМ ====================
  # asusctl - вентиляторы, профили, подсветка
  services.asusd = {
    enable = true;
    enableUserService = true;
  };

  # supergfxd - переключение режимов GPU
  services.supergfxd.enable = true;

  # Power profiles daemon (управление энергопотреблением)
  services.power-profiles-daemon.enable = true;

  # ==================== ЗВУК ====================
  # PipeWire - современный звуковой сервер
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true; # Для совместимости
    wireplumber.enable = true;
  };

  # ==================== PORTAL ДЛЯ WAYLAND ====================
  # Нужны для скринкастов, выбора файлов и прочего
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
    # Утилиты Wayland
    wayland-utils         # Информация о Wayland
    wlr-randr            # Управление мониторами
    wl-clipboard         # Буфер обмена
    wl-screenrec         # Запись экрана
    grim                 # Скриншоты (для Wayland)
    slurp                # Выбор области для скриншотов
    
    # Утилиты
    kitty                # Терминал
    fuzzel               # Лаунчер приложений
    mako                 # Уведомления
    waybar               # Статус-бар (опционально, можно убрать)
    
    # Системные
    pciutils             # Просмотр PCI-устройств
    usbutils             # Просмотр USB-устройств
    glxinfo              # Информация о GL
    vulkan-tools         # Информация о Vulkan
    
    # asusctl (уже включён сервисом, но CLI полезен)
    asusctl
    
    # Архиваторы и файловые менеджеры
    unzip
    unrar
  ];

  # ==================== STEAM И ИГРЫ ====================
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
    extraCompatPackages = with pkgs; [
      proton-ge-bin  # Proton-GE
    ];
  };

  # GameMode для оптимизации игр
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

  # ==================== ДРУГОЕ ====================
  # Поддержка сжатия zstd
  nix.settings.auto-optimise-store = true;
  
  # Сборщик мусора (чистит старые поколения)
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  # Версия системы (не менять после первой установки)
  system.stateVersion = "25.11";
}