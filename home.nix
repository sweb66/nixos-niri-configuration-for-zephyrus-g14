{ config, lib, pkgs, inputs, user, ... }:

{
  home.username = "${user}";
  home.homeDirectory = "/home/${user}";
  home.stateVersion = "25.11";

  # ==================== ПАКЕТЫ ПОЛЬЗОВАТЕЛЯ ====================
  home.packages = with pkgs; [
    # Браузеры
    firefox
    google-chrome  # На случай если нужен Chrome
    
    # Мессенджеры
    telegram-desktop
    discord
    
    # Офисные
    libreoffice
    
    # Медиа
    mpv               # Видеоплеер
    imv               # Просмотр изображений (Wayland)
    nautilus          # Файловый менеджер
    
    # Разработка
    git
    vscode
    python3
    
    # Шрифты
    noto-fonts-emoji
  ];

  # ==================== ПЕРЕМЕННЫЕ ОКРУЖЕНИЯ ====================
  home.sessionVariables = {
    # Wayland
    XDG_SESSION_TYPE = "wayland";
    # Niri
    NIRI_CONFIG = "${config.xdg.configHome}/niri/config.kdl";
    # OpenGL
    __GL_GSYNC_ALLOWED = "0";
    __GL_VRR_ALLOWED = "0";
    # Firefox
    MOZ_ENABLE_WAYLAND = "1";
    # Qt
    QT_QPA_PLATFORM = "wayland";
    # SDL
    SDL_VIDEODRIVER = "wayland";
    # Java
    _JAVA_AWT_WM_NONREPARENTING = "1";
  };

  # ==================== FIREFOX (NATIVE WAYLAND) ====================
  programs.firefox = {
    enable = true;
    package = pkgs.firefox;
  };

  # ==================== GIT ====================
  programs.git = {
    enable = true;
    userName = "Твоё Имя";
    userEmail = "твоя@почта.com";
  };

  # ==================== WAYBAR (ОПЦИОНАЛЬНО) ====================
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 30;
        modules-left = [ "niri/workspaces" ];
        modules-center = [ "clock" ];
        modules-right = [ "cpu" "memory" "pulseaudio" "battery" "tray" ];
        
        "niri/workspaces" = {
          format = "{name}";
        };
        
        clock = {
          format = "{:%H:%M}";
          tooltip-format = "{:%Y-%m-%d}";
        };
        
        cpu = {
          format = "CPU {usage}%";
        };
        
        memory = {
          format = "RAM {}%";
        };
        
        pulseaudio = {
          format = "{volume}% {icon}";
          format-icons = ["🔈" "🔉" "🔊"];
        };
        
        battery = {
          format = "{capacity}% {icon}";
          format-icons = ["🔋" "🪫"];
        };
      };
    };
    
    style = ''
      * {
        font-family: "JetBrains Mono Nerd Font";
        font-size: 14px;
        border: none;
        border-radius: 0;
        min-height: 0;
      }
      
      window#waybar {
        background: #1a1b26;
        color: #a9b1d6;
      }
    '';
  };

  # ==================== ДЕЛАЕМ NIRI ДЕФОЛТНЫМ СЕАНСОМ ====================
  # Чтобы при логине в tty запускался niri
  programs.bash.profileExtra = ''
    if [ -z "$DISPLAY" ] && [ "''${XDG_VTNR}" -eq 1 ]; then
      exec niri-session
    fi
  '';
}