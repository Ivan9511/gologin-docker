#!/bin/bash

mkdir -p ~/.vnc
export DISPLAY=:0

echo "Resolution: ${SCREEN_WIDTH}x${SCREEN_HEIGHT}x16"

cd /opt/orbita

Xvfb $DISPLAY -screen 0 ${SCREEN_WIDTH}x${SCREEN_HEIGHT}x16 &
sleep 3

x11vnc -storepasswd 12345678 ~/.vnc/passwd
x11vnc -display $DISPLAY -bg -forever -usepw -quiet -rfbport 5901 -xkb

/usr/sbin/nginx -c /etc/nginx/nginx.conf

python3 main.py
