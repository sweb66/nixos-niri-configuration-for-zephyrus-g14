
```markdown
# 🐧 NixOS Configuration for ASUS Zephyrus G14 (2021)

> Полная конфигурация NixOS 25.11 для ноутбука ASUS Zephyrus G14 GA401IU с гибридной графикой AMD+NVIDIA, оконным менеджером Niri и поддержкой игр через Steam/Proton.

## 📋 Спецификации

| Компонент | Модель |
|-----------|--------|
| **Ноутбук** | ASUS Zephyrus G14 GA401IU (2021) |
| **Процессор** | AMD Ryzen 7 4800HS |
| **Графика** | AMD Radeon Vega 7 + NVIDIA GTX 1660 Ti |
| **Ядро** | Linux 7.0 |
| **ОС** | NixOS 25.11 |
| **Оконный менеджер** | Niri (Wayland) |
| **Звук** | PipeWire |
| **Охлаждение** | asusctl + supergfxd |

## 🎯 Возможности

- ✅ Полная поддержка гибридной графики (AMD + NVIDIA Prime Offload)
- ✅ Автоматическое управление питанием и вентиляторами (asusctl)
- ✅ Переключение режимов GPU (supergfxd)
- ✅ Игры через Steam + Proton-GE
- ✅ GameMode для оптимизации производительности в играх
- ✅ Wayland из коробки (без X11)
- ✅ Автоматическая очистка старых поколений Nix
- ✅ Русская локаль и раскладка клавиатуры
- ✅ Настроенные горячие клавиши для Niri

## 📁 Структура конфигурации

```

.
├── flake.nix              # Входная точка, описание inputs и outputs
├── configuration.nix      # Системная конфигурация
├── home.nix               # Пользовательские настройки (Home Manager)
└── README.md              # Этот файл

```

## 🚀 Быстрый старт

### 1. Клонируем репозиторий

git clone https://github.com/sweb66/nixos-niri-configuration-for-zephyrus-g14 /tmp/nixos-config
sudo cp -r /tmp/nixos-config/* /etc/nixos/
cd /etc/nixos
```

2. Настраиваем под себя

2.1 Меняем имя пользователя

В файле flake.nix найди строку:

```nix
user = "user"; # !!! ЗАМЕНИ НА СВОЁ ИМЯ ПОЛЬЗОВАТЕЛЯ !!!
```

Замени "user" на свой username.

2.2 Узнаём UUID разделов

```bash
lsblk -f
```

Пример вывода:

```
nvme0n1
├─nvme0n1p1 vfat   FAT32       ABCD-1234
├─nvme0n1p2 ext4   1.0         a1b2c3d4-e5f6-7890-abcd-ef1234567890
└─nvme0n1p3 swap   1           f9e8d7c6-b5a4-3210-fedc-ba9876543210
```

2.3 Прописываем UUID в configuration.nix

В файле configuration.nix найди секцию fileSystems и замени:

```nix
fileSystems."/" = {
  device = "/dev/disk/by-uuid/a1b2c3d4-e5f6-7890-abcd-ef1234567890"; # ← твой UUID корневого раздела
  fsType = "ext4";
};

fileSystems."/boot" = {
  device = "/dev/disk/by-uuid/ABCD-1234"; # ← твой UUID boot раздела
  fsType = "vfat";
};

swapDevices = [
  { device = "/dev/disk/by-uuid/f9e8d7c6-b5a4-3210-fedc-ba9876543210"; } # ← твой UUID swap
];
```

3. Собираем систему

```bash
sudo nixos-rebuild switch --flake /etc/nixos#g14
```

4. Перезагружаемся

```bash
sudo reboot
```

5. Первый вход

· Логинимся под своим пользователем
· Пароль по умолчанию: changeme
· Сразу меняем пароль: passwd

🎮 Игры через Steam

Запуск Steam с дискретной видеокартой

```bash
nvidia-offload steam
```

Принудительный запуск игр на NVIDIA

В свойствах игры в Steam, в параметрах запуска добавить:

```
nvidia-offload %command%
```

Или использовать gamemode вместе:

```
nvidia-offload gamemoderun %command%
```

Proton-GE

Proton-GE уже установлен в системе. Для использования:

1. Steam → Настройки → Совместимость
2. Включить "Включить Steam Play для всех продуктов"
3. Выбрать "Proton-GE" из выпадающего списка

🔧 Управление ноутбуком

Профили производительности (asusctl)

```bash
# Посмотреть текущий профиль
asusctl profile -p

# Переключить на следующий профиль
asusctl profile -n

# Доступные профили: Quiet, Balanced, Performance
```

Режимы GPU (supergfxd)

```bash
# Посмотреть текущий режим
supergfxctl -g

# Переключить режим
supergfxctl -m integrated  # Только AMD (экономия батареи)
supergfxctl -m hybrid      # Гибридный (AMD + NVIDIA)
supergfxctl -m nvidia      # Только NVIDIA (макс. производительность)
```

⌨️ Горячие клавиши Niri

Сочетание Действие
Mod + T Терминал (kitty)
Mod + D Лаунчер приложений (fuzzel)
Mod + B Браузер (Firefox)
Mod + Q Закрыть окно
Mod + F Полный экран
Mod + Shift + E Выйти из Niri
Mod + H/L Фокус окна влево/вправо
Mod + J/K Фокус окна вниз/вверх
Mod + Ctrl + H/L/J/K Переместить окно
Mod + 1-4 Переключить рабочий стол
Mod + Shift + 1-4 Переместить окно на рабочий стол

📦 Установленные компоненты

Системные

· Дисплейный сервер: Wayland
· Композитор: Niri
· Терминал: Kitty
· Лаунчер: Fuzzel
· Уведомления: Mako
· Статус-бар: Waybar
· Управление мониторами: wlr-randr
· Скриншоты: grim + slurp
· Запись экрана: wl-screenrec

Пользовательские

· Браузер: Firefox, Google Chrome
· Мессенджеры: Telegram, Discord
· Офис: LibreOffice
· Медиа: MPV, IMV
· Файловый менеджер: Nautilus
· Разработка: Git, VS Code, Python

🔄 Обновление системы

```bash
cd /etc/nixos
nix flake update
sudo nixos-rebuild switch --flake /etc/nixos#g14
```

🧹 Очистка старых поколений

Настроена автоматическая очистка каждую неделю (хранятся поколения за 7 дней).

Ручная очистка:

```bash
sudo nix-collect-garbage -d
```

⚠️ Возможные проблемы

Не запускается Niri

```bash
# Запустить вручную
niri-session

# Проверить логи
journalctl -u niri -f
```

Не работает NVIDIA

```bash
# Проверить, что драйвер загружен
lsmod | grep nvidia

# Проверить BusId
lspci | grep -E "VGA|3D"

# Проверить работу offload
nvidia-offload glxinfo | grep "OpenGL renderer"
```

Проблемы с asusctl

```bash
# Проверить статус демона
systemctl status asusd

# Перезапустить
sudo systemctl restart asusd

# Проверить модули ядра
lsmod | grep asus
```

🔧 Кастомизация

Добавление своих программ

В home.nix добавить пакеты в home.packages:

```nix
home.packages = with pkgs; [
  # ... существующие пакеты ...
  obs-studio      # OBS для стримов
  gimp            # Графический редактор
  spotify         # Музыка
];
```

Изменение горячих клавиш Niri

Править секцию binds в configuration.nix → environment.etc."niri/config.kdl".

Смена темы Waybar

Править секцию style в home.nix → programs.waybar.