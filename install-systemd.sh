#!/bin/sh

wsl.exe -d "$WSL_DISTRO_NAME" -u root -- apt-get update
wsl.exe -d "$WSL_DISTRO_NAME" -u root -- apt-get install -yqq daemonize

wsl.exe -d "$WSL_DISTRO_NAME" -u root -- ln -sf /dev/null /etc/systemd/system/getty@tty1.service
wsl.exe -d "$WSL_DISTRO_NAME" -u root -- ln -sf /dev/null /etc/systemd/system/iscsi.service
wsl.exe -d "$WSL_DISTRO_NAME" -u root -- ln -sf /dev/null /etc/systemd/system/multipath-tools.service
wsl.exe -d "$WSL_DISTRO_NAME" -u root -- ln -sf /dev/null /etc/systemd/system/multipathd.service
wsl.exe -d "$WSL_DISTRO_NAME" -u root -- ln -sf /dev/null /etc/systemd/system/systemd-remount-fs.service
wsl.exe -d "$WSL_DISTRO_NAME" -u root -- ln -sf /dev/null /etc/systemd/system/systemd-resolved.service
wsl.exe -d "$WSL_DISTRO_NAME" -u root -- ln -sf /dev/null /etc/systemd/system/vmtoolsd.service
wsl.exe -d "$WSL_DISTRO_NAME" -u root -- ln -sf /dev/null /etc/systemd/system/iscsid.socket
wsl.exe -d "$WSL_DISTRO_NAME" -u root -- ln -sf /dev/null /etc/systemd/system/multipathd.socket

wsl.exe -d "$WSL_DISTRO_NAME" -u root -- tee /usr/sbin/start-systemd-namespace > /dev/null <<'EOF'
#!/bin/sh

if [ "$USER" != "root" ]; then
    echo "You must be root to run this script"
    exit 1
fi

SYSTEMD_PID="$(ps -eo pid=,args= | awk '$2" "$3=="systemd --unit=multi-user.target" { print $1 }')"
if [ -z "$SYSTEMD_PID" ]; then
    /usr/bin/daemonize /usr/bin/unshare --fork --mount-proc --pid -- /bin/sh -c "
        mount -t binfmt_misc binfmt_misc /proc/sys/fs/binfmt_misc
        exec systemd --unit=multi-user.target
    "
    while [ -z "$SYSTEMD_PID" ]; do
        SYSTEMD_PID="$(ps -eo pid=,args= | awk '$2" "$3=="systemd --unit=multi-user.target" { print $1 }')"
        sleep 1
    done
    nsenter -m -p -t "$SYSTEMD_PID" systemctl set-environment DISPLAY="$(awk '/nameserver/ { print $2":0" }' /etc/resolv.conf)"
    nsenter -m -p -t "$SYSTEMD_PID" systemctl set-environment WSL_INTEROP="$(ls -t /run/WSL/*_interop | head -1)"
    nsenter -m -p -t "$SYSTEMD_PID" systemctl set-environment WSL_DISTRO_NAME="$WSL_DISTRO_NAME"
fi
echo "$SYSTEMD_PID"
EOF
wsl.exe -d "$WSL_DISTRO_NAME" -u root -- chmod +x /usr/sbin/start-systemd-namespace

wsl.exe -d "$WSL_DISTRO_NAME" -u root -- tee /usr/bin/namespaced-shell-wrapper.sh > /dev/null <<'EOF'
#!/bin/sh

ME="$0"
SHELL="$(echo "$0" | sed -e 's/namespaced-//')"

if [ "$USER" != "root" ]; then
    export | sed -Ee 's/^(export )?PATH=.*//' > "$HOME/.wsl_env"
    exec wsl.exe -d "$WSL_DISTRO_NAME" -u root -e env SUDO_USER="$USER" "$ME" "$@"
fi

SYSTEMD_PID="$(/usr/sbin/start-systemd-namespace)"

if [ "$1" = "-c" ]; then
    shift
    HOME="$(eval echo "$(echo "~$SUDO_USER")")"
    exec nsenter -m -p -t "$SYSTEMD_PID" runuser --user "$SUDO_USER" -- sh -c ". '$HOME/.wsl_env'; $@"
else
    exec nsenter -m -p -t "$SYSTEMD_PID" runuser --shell="$SHELL" --login "$SUDO_USER"
fi
EOF

wsl.exe -d "$WSL_DISTRO_NAME" -u root -- tee /etc/profile.d/00-wsl2-systemd-env.sh > /dev/null <<'EOF'
. "$HOME/.wsl_env"
if [ -n "$PWD" ]; then
    cd "$PWD";
fi
EOF

wsl.exe -d "$WSL_DISTRO_NAME" -u root -- tee /etc/profile.d/zz-wsl2-systemd-path.sh > /dev/null <<'EOF'
export PATH="$PATH:$(wslvar PATH 2>/dev/null | awk 'BEGIN { RS=";"; FS="\n" } { "wslpath '\''" $0 "'\''" | getline; printf "%s%s",sep,$1; sep=":" }')"
EOF

NEWSHELL="$(dirname "$SHELL")/namespaced-$(basename "$SHELL")"

wsl.exe -d "$WSL_DISTRO_NAME" -u root -- ln -sf "/usr/bin/namespaced-shell-wrapper.sh" "$NEWSHELL"
wsl.exe -d "$WSL_DISTRO_NAME" -u root -- chmod +x "/usr/bin/namespaced-shell-wrapper.sh"
wsl.exe -d "$WSL_DISTRO_NAME" -u root -- chsh --shell "$NEWSHELL" "$USER"

unset NEWSHELL
