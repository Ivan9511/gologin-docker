# Запуск Gologin в Docker контейнере.

Разработано на основе https://github.com/gologinapp/docker

Данный Docker контейнер предназначен для запуска браузера Gologin в изолированной среде с использованием Python 3.12, Xvfb для виртуального дисплея, x11vnc для VNC-доступа и Nginx для веб-интерфейса. Контейнер поддерживает настройку разрешения экрана через переменные окружения и сохраняет скриншоты сделанные через selenium webdriver в монтируемую директорию на хост-машине.


# Сборка Docker образа:
В директории с файлами выполните сборку образа:

    docker build -t gologin-browser .
# Запуск контейнера:

    docker run -e SCREEN_WIDTH=1920 -e SCREEN_HEIGHT=1080 -p 3000:3000 -p 5901:5901 -v /home/user/screenshots:/opt/orbita/screenshots gologin-browser
Параметры команды:

    -e SCREEN_WIDTH=1920 — ширина экрана.
    -e SCREEN_HEIGHT=1080 — высота экрана.
    -p 3000:3000 — порт для веб-интерфейса.
    -p 5901:5901 — порт для VNC.
    -v /home/user/screenshots:/opt/orbita/screenshots — монтирование директории для скриншотов.
    gologin-browser — имя Docker образа.


  # Структура контейнера:
## Dockerfile:
  
- Базовый образ: python:3.12-slim.
    
- Установка зависимостей: Устанавливаются пакеты для работы Xvfb, x11vnc, Nginx, шрифтов и библиотек для браузера.
    
 - Orbita Browser: Загружается и распаковывается из orbita-browser-latest.tar.gz.
    
 - ChromeDriver: Устанавливается версия 135.0.7049.114.
    
 - Python зависимости: Устанавливаются из requirements.txt.
    
 - Пользователь: Создаётся пользователь orbita с правами sudo.
    
 - Директории: Создаётся /opt/orbita/screenshots с правами 777 и монтируется к хосту.
    
 - Nginx: Конфигурация из orbita.conf копируется в /etc/nginx/conf.d/.
    
 - Точка входа: Скрипт entrypoint.sh.
    

## entrypoint.sh:

- Создаёт директорию для VNC (~/.vnc).
    
- Запускает Xvfb с заданным разрешением (${SCREEN_WIDTH}x${SCREEN_HEIGHT}x16).
    
- Настраивает x11vnc с паролем 12345678 на порту 5901.
    
- Запускает Nginx.
    
- Выполняет main.py для инициализации браузера.
  
