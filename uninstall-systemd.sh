#!/bin/sh

NEWSHELL="$(dirname "$SHELL")/namespaced-$(basename "$SHELL")"

wsl.exe -d "$WSL_DISTRO_NAME" -u root -- wsl.exe -d "$WSL_DISTRO_NAME" -u root -- chsh --shell "$SHELL" "$USER"
wsl.exe -d "$WSL_DISTRO_NAME" -u root -- "$NEWSHELL"
wsl.exe -d "$WSL_DISTRO_NAME" -u root -- /etc/profile.d/zz-wsl2-systemd-path.sh
wsl.exe -d "$WSL_DISTRO_NAME" -u root -- /etc/profile.d/00-wsl2-systemd-env.sh
wsl.exe -d "$WSL_DISTRO_NAME" -u root -- /usr/bin/namespaced-shell-wrapper.sh
wsl.exe -d "$WSL_DISTRO_NAME" -u root -- /usr/sbin/start-systemd-namespace
