#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

ESC="["

dim="${ESC}2m"
underline="${ESC}4m"

black="${ESC}30m"
red="${ESC}31m"
green="${ESC}32m"
yellow="${ESC}33m"
blue="${ESC}34m"
purple="${ESC}35m"
cyan="${ESC}36m"
gray="${ESC}37m"

clear="${ESC}0m"

cat <<EOF
${green}1.  Set up ethernet based networking using netplan${clear}

- edit ${dim}/etc/netplan/01-netcfg.yaml${clear} to have the following:

  ${dim}ethernets:
    <name-of-link>:
      dhcp4: true${clear}

${underline}Links${clear}
$(ls -1 /sys/class/net | sed 's/^/  /g')

Press enter to continue...
EOF
read

sudo vim /etc/netplan/01-netcfg.yaml
sudo netplan apply
echo "Waiting 15 seconds for interface to come up"
sleep 15
ip addr
ping -c 5 -q google.com

# WiFi
cat <<EOF
${green}2.  Update all packages and get WiFi working${clear}

- apt update
- apt update
- apt install wpasupplicant
- edit ${dim}/etc/netplan/01-netcfg.yaml${clear} to have the following:

  ${dim}wifis:
    <name-of-link>:
      dhcp4: true
      access-points:
        "<name>":
          password: "<password>"${clear}

${underline}Links${clear}
$(ls -1 /sys/class/net | sed 's/^/  /g')

Press enter to continue...
EOF
read

sudo apt update
sudo apt upgrade
sudo apt install --yes wpasupplicant
sudo vim /etc/netplan/01-netcfg.yaml
sudo netplan apply
echo "Waiting 15 seconds for interface to come up"
sleep 15
ip addr
ping -c 5 -q google.com

echo "You may unplug the ethernet cable now"

sudo apt purge tmux apport byobu screen
sudo apt install --no-install-recommends manpages-dev           # GNU/Linux manpages
sudo apt install --no-install-recommends xserver-xorg           # X11 server
sudo apt install --no-install-recommends xorg-docs-core         # Docs for X
sudo apt install --no-install-recommends xinit                  # xinit + startx
sudo apt install --no-install-recommends x11-xserver-utils      # tools like xrandr, xmodmap, xrdb, etc.
sudo apt install --no-install-recommends x11-utils              # tools like xdpyinfo, xev, xfontsel, xkill, etc.
sudo apt install --no-install-recommends xdg-utils              # tools like xdg-open, xdg-desktop-menu, xdg-settings, etc.
sudo apt install --no-install-recommends mesa-utils             # tools like glxinfo, glxgears, glxinfo, glxheads
sudo apt install --no-install-recommends alsa-utils             # tools like amixer, aplay, alsaloop, speaker-test, etc.
sudo apt install --no-install-recommends dbus-x11               # dbus-launch
sudo apt install --no-install-recommends make                   # lol
git clone "https://github.com/gurpreetatwal/dotfiles" "$HOME/dotfiles"
cd "$HOME/dotfiles"
make alacritty
make i3
sudo apt install --no-install-recommends firefox                # see above
sudo apt install --no-install-recommends chromium-browser       # see above
sudo apt install --no-install-recommends apulse                 # pulse -> alsa bridge, needed for firefox
