#!/bin/sh

wsl.exe -d "$WSL_DISTRO_NAME" -u root -- rm -f /usr/share/applications/wslview.desktop
wsl.exe -d "$WSL_DISTRO_NAME" -u root -- rm -f /etc/profile.d/zz-wsl2-systemd-display.sh
wsl.exe -d "$WSL_DISTRO_NAME" -u root -- update-desktop-database
