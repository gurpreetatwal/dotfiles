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

install() {
  sudo apt install --no-install-recommends --quiet --quiet $@
}

install manpages-dev           # GNU/Linux manpages
install xserver-xorg           # X11 server
install xorg-docs-core         # Docs for X
install xinit                  # xinit + startx
install xinput                 # xinput
install x11-xserver-utils      # tools like xrandr, xmodmap, xrdb, etc.
install x11-utils              # tools like xdpyinfo, xev, xfontsel, xkill, etc.
install xdg-utils              # tools like xdg-open, xdg-desktop-menu, xdg-settings, etc.
install mesa-utils             # tools like glxinfo, glxgears, glxinfo, glxheads
install alsa-utils             # tools like amixer, aplay, alsaloop, speaker-test, etc.
install dbus-x11               # dbus-launch
install cgroup-tools           # tools like cgcreate, cgexec, cgdelete, etc.
install make                   # lol
git clone "https://github.com/gurpreetatwal/dotfiles" "$HOME/dotfiles"
cd "$HOME/dotfiles"
make alacritty
make i3
install firefox                # see above
install chromium-browser       # see above
install apulse                 # pulse -> alsa bridge, needed for firefox
