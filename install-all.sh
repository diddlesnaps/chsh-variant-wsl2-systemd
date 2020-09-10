#!/bin/sh

DIR="$(dirname $0)"
[ -z "$DIR" ] && DIR="."

"$DIR/install-systemd.sh" --nospawn
"$DIR/install-gui-support.sh"

NEWSHELL="$(dirname "$SHELL")/namespaced-$(basename "$SHELL")"
exec "$NEWSHELL"

