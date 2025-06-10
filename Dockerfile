FROM python:3.12-slim

# Переменные окружения
ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=:0

RUN ln -fs /usr/share/zoneinfo/America/New_York /etc/localtime

RUN apt-get update && \
    apt-get install -y tzdata && \
    dpkg-reconfigure --frontend noninteractive tzdata && \
    apt-get install -y \
        x11vnc xvfb zip wget curl psmisc supervisor \
        gconf-service libasound2 libatk1.0-0 libatk-bridge2.0-0 libc6 \
        libcairo2 libcups2 libdbus-1-3 libexpat1 libfontconfig1 libgcc1 \
        libgconf-2-4 libgdk-pixbuf2.0-0 libglib2.0-0 libgtk-3-bin libnspr4 \
        libpango-1.0-0 libpangocairo-1.0-0 libstdc++6 libx11-6 libx11-xcb1 \
        libxcb1 libxcomposite1 libxcursor1 libxdamage1 libxext6 libxfixes3 \
        libxi6 libxrandr2 libxrender1 libxss1 libxtst6 ca-certificates \
        fonts-liberation libappindicator1 libnss3 lsb-release xdg-utils \
        libgbm-dev nginx libcurl3-gnutls dbus && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Установка Orbita Browser
RUN wget https://orbita-browser-linux.gologin.com/orbita-browser-latest.tar.gz -O /tmp/orbita-browser.tar.gz && \
    tar -xzf /tmp/orbita-browser.tar.gz -C /usr/bin && \
    rm -f /tmp/orbita-browser.tar.gz

# Удаляем chromedriver из архива Orbita, если он есть
RUN rm -f /usr/bin/orbita-browser/chromedriver

# Установка ChromeDriver версии 135.0.7049.114
RUN wget https://storage.googleapis.com/chrome-for-testing-public/135.0.7049.114/linux64/chromedriver-linux64.zip -O /tmp/chromedriver.zip && \
    unzip /tmp/chromedriver.zip chromedriver-linux64/chromedriver -d /usr/bin/orbita-browser/ && \
    mv /usr/bin/orbita-browser/chromedriver-linux64/chromedriver /usr/bin/orbita-browser/chromedriver && \
    rmdir /usr/bin/orbita-browser/chromedriver-linux64 && \
    chmod +x /usr/bin/orbita-browser/chromedriver && \
    rm -f /tmp/chromedriver.zip

COPY requirements.txt /opt/orbita/requirements.txt
RUN python3 -m pip install --upgrade pip && \
    pip3 install -r /opt/orbita/requirements.txt

RUN groupadd -r orbita && \
    useradd -r -g orbita -s /bin/bash -G audio,video,sudo -p $(echo 1 | openssl passwd -1 -stdin) orbita && \
    mkdir -p /home/orbita/Downloads && \
    chown -R orbita:orbita /home/orbita

RUN echo 'orbita ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

RUN mkdir -p /home/orbita/.gologin/browser
COPY fonts /home/orbita/.gologin/browser/fonts

RUN mkdir -p /opt/orbita/screenshots && chmod 777 /opt/orbita/screenshots

RUN rm /etc/nginx/sites-enabled/default
COPY orbita.conf /etc/nginx/conf.d/orbita.conf
RUN chmod 777 /var/lib/nginx -R && \
    chmod 777 /var/log -R && \
    chmod 777 /run -R && \
    chmod 1777 /tmp

RUN usermod -a -G sudo orbita

COPY main.py /opt/orbita/main.py
COPY entrypoint.sh /entrypoint.sh

COPY browser_starter.py /opt/orbita/browser_starter.py

RUN chmod 777 /entrypoint.sh && \
    mkdir /tmp/.X11-unix && \
    chmod 1777 /tmp/.X11-unix

USER orbita
WORKDIR /opt/orbita

EXPOSE 3000

ENTRYPOINT ["/entrypoint.sh"]