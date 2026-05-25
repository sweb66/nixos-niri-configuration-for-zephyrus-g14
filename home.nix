{ config, lib, pkgs, inputs, user, ... }:

{
  home.username = "${user}";
  home.homeDirectory = "/home/${user}";
  home.stateVersion = "25.11";

  home.packages = with pkgs; [
    firefox
    google-chrome
    telegram-desktop
    discord
    libreoffice
    mpv
    imv
    nautilus
    git
    vscode
    python3
    noto-fonts-emoji
  ];

  # Переменные окружения
  home.sessionVariables = {
    XDG_SESSION_TYPE = "wayland";
    MOZ_ENABLE_WAYLAND = "1";
    QT_QPA_PLATFORM = "wayland";
    SDL_VIDEODRIVER = "wayland";
    _JAVA_AWT_WM_NONREPARENTING = "1";
    __GL_GSYNC_ALLOWED = "0";
    __GL_VRR_ALLOWED = "0";
  };

  # Git
  programs.git = {
    enable = true;
    userName = "Твоё Имя";
    userEmail = "твоя@почта.com";
  };

  # Waybar
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

  # Автостарт niri при входе в tty
  programs.bash.profileExtra = ''
    if [ -z "$DISPLAY" ] && [ "''${XDG_VTNR}" -eq 1 ]; then
      exec niri-session
    fi
  '';
}