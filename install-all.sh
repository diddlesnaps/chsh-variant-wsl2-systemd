#!/bin/sh

DIR="$(dirname $0)"
[ -z "$DIR" ] && DIR="."

"$DIR/install-systemd.sh"
"$DIR/install-gui-support.sh"
