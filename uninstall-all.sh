#!/bin/sh

DIR="$(dirname $0)"
[ -z "$DIR" ] && DIR="."

"$DIR/uninstall-systemd.sh"
"$DIR/uninstall-gui-support.sh"
