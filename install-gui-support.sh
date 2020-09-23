#!/bin/sh

wsl.exe -d "$WSL_DISTRO_NAME" -u root -- apt-get install -yqq desktop-file-utils xdg-desktop-portal-gtk x11-xserver-utils

wsl.exe -d "$WSL_DISTRO_NAME" -u root -- tee /etc/profile.d/zz-wsl2-systemd-display.sh > /dev/null <<'EOF'
export DISPLAY="$(awk '/nameserver/ { print $2":0" }' /etc/resolv.conf)"
if ! xset q &>/dev/null; then
    unset DISPLAY
fi
EOF

wsl.exe -d "$WSL_DISTRO_NAME" -u root -- chmod 644 /etc/profile.d/zz-wsl2-systemd-display.sh

wsl.exe -d "$WSL_DISTRO_NAME" -u root -- tee /usr/share/applications/wslview.desktop > /dev/null <<'EOF'
[Desktop Entry]
Name=WSLView
Comment=Open files and addresses in Windows
Icon=windows
Exec=/usr/bin/wslview %U
Terminal=false
Type=Application
Categories=Utility;
MimeType=x-scheme-handler/http;x-scheme-handler/https;x-scheme-handler/file
EOF

wsl.exe -d "$WSL_DISTRO_NAME" -u root -- update-desktop-database
