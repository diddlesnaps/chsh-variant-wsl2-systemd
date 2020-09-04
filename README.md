# WSL2 Systemd by changing the user's shell

## About
This repository includes the files to set-up WSL2 distro to run systemd.

## What does it do?
- Disables a few Systemd units that aren't required for WSL2 or might cause issues
- Creates a minimal script called `/etc/profile.d/00-wsl2-systemd.sh` that sets up some WSL2-specific environment that cannot be carried into the Systemd namespace easily. At the moment this is only the `PATH` variable
- Creates a file called `/usr/sbin/start-systemd-namespace` that is used to start Systemd inside a PID namespace so that Systemd is PID 1
- Creates a file called `/usr/bin/namespaced-shell-wrapper.sh` that will call `start-systemd-namespace` to enter the systemd namespace. It will then execute your shell
- Symlinks `namespaced-shell-wrapper.sh` alongside your current user shell's executable. For example, if you are running BASH with executable `/bin/bash` then it will create the symlink as `/bin/namespaced-bash`
- Modifies `/etc/pam.d/runuser` to allow the usage of a user-specific environment override file that is enforced by the PAM subsystem. The file, `$HOME/.pam_environment` is written by `/usr/bin/namespaced-shell-wrapper.sh` and contains variables that should not change often
- Finally, changes your user's configured shell with `chsh` to point to the symlink to the shell wrapper, e.g. `/bin/namespaced-bash`.

## Installing
1. Clone the repository, or download the three scripts via a browser
1. Execute either `install-all.sh` or `install-systemd.sh`.
   - The `install-all.sh` script will execute both `install-systemd.sh` and `install-gui-support.sh` to perform a complete install
   - `install-systemd.sh` will install just enough to get systemd operational, but will not enable GUI support via X11
   - If you install the GUI support by running `install-all.sh` (or `install-gui-support.sh` after running `install-systemd.sh`) it is advisable to ensure that you have an X11 server on your Windows system that is listening for connections while using your WSL2 distro, else you might find some Linux commands stall or fail
1. Restart your WSL2 session

## Alternatives
- [Damion Gans' installer for the two-script variant](https://github.com/damionGans/ubuntu-wsl2-systemd-script/)
- [My one-script variant using `/etc/profile.d/00-wsl2-systemd.sh`](https://github.com/diddlesnaps/one-script-wsl2-systemd)
