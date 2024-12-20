
# default XDG user directories if they are not set
# @see https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html#basics
XDG_CONFIG_HOME ?= $(HOME)/.config
XDG_CACHE_HOME ?= $(HOME)/.cache
XDG_DATA_HOME ?= $(HOME)/.local/share
XDG_STATE_HOME ?= $(HOME)/.local/state
SHELL := /bin/bash

tmux: version ?= 2.6
maven: version ?= 3.6.3
gradle: version ?= 6.8.3
stterm: version ?= 0.8.1
flags/docker-compose: compose-version ?= 1.29.1
npm-%: packages = browser-sync bunyan eslint_d geckodriver gulp-cli html nodemon ndb prettier tern

.PHONY:
	install
	pgcli
	npm
	npm-install
	npm-update

install:
	./install.sh

basic: apt.tree apt.silversearcher-ag apt.xclip apt.jq
	mkdir -p $(HOME)/bin
	mkdir -p $(HOME)/temp
	mkdir -p "$(XDG_CONFIG_HOME)"
	mkdir -p "$(XDG_CACHE_HOME)"
	mkdir -p "$(XDG_DATA_HOME)"
	mkdir -p "$(XDG_STATE_HOME)"
	test -d $(HOME)/scripts/.git || git clone https://github.com/gurpreetatwal/scripts.git  $(HOME)/scripts
	@bash ./install/run-helper link "shell/profile" "$(HOME)/.profile"
	@bash ./install/run-helper link "user-dirs.sh" "$(XDG_CONFIG_HOME)/user-dirs.dirs"
	mkdir -p "$(XDG_CONFIG_HOME)/ag"
	@bash ./install/run-helper link "agignore" "$(XDG_CONFIG_HOME)/ag/ignore"
	mkdir -p "$(XDG_CONFIG_HOME)/git"
	@bash ./install/run-helper link "gitconfig" "$(XDG_CONFIG_HOME)/git/config"
	@bash ./install/run-helper link "gitignore.global" "$(XDG_CONFIG_HOME)/git/ignore"

zsh: apt.zsh
	grep --quiet "$$(whoami):$$(which zsh)$$" /etc/passwd || sudo usermod --shell "$$(which zsh)" "$$(whoami)"
	grep --quiet --fixed-strings 'ZDOTDIR="$$HOME/.config/zsh"' "/etc/zsh/zshenv" || \
		echo 'ZDOTDIR="$$HOME/.config/zsh"' | sudo tee -a "/etc/zsh/zshenv"
	mkdir --parents "$(XDG_CONFIG_HOME)/zsh"
	@bash ./install/run-helper link "shell/zshrc" "$(XDG_CONFIG_HOME)/zsh/.zshrc"
	@bash ./install/run-helper link "shell/profile" "$(XDG_CONFIG_HOME)/zsh/.zprofile"
	mkdir --parents "$(XDG_DATA_HOME)/zsh"
	@bash ./install/run-helper git-clone "https://github.com/romkatv/powerlevel10k" "$(XDG_DATA_HOME)/zsh/powerlevel10k"
	@bash ./install/run-helper git-clone "https://github.com/zsh-users/zsh-completions.git" "$(XDG_DATA_HOME)/zsh/completions"
	mkdir --parents "$(XDG_STATE_HOME)/zsh" # history is stored here
	mkdir --parents "$(XDG_CACHE_HOME)/zsh" # completion cache is stored here

.PHONY: fzf
FZF_FILES = $(XDG_DATA_HOME)/fzf/bin/fzf $(XDG_CONFIG_HOME)/fzf/fzf.bash $(XDG_CONFIG_HOME)/fzf/fzf.zsh
fzf: $(XDG_DATA_HOME)/fzf $(FZF_FILES)
$(XDG_DATA_HOME)/fzf:
	@bash ./install/run-helper git-clone "https://github.com/junegunn/fzf.git" "$(XDG_DATA_HOME)/fzf" --depth 1

$(FZF_FILES):
	"$(XDG_DATA_HOME)/fzf/install" --xdg --key-bindings --completion --no-update-rc --no-fish

.PHONY: fasd
fasd: $(HOME)/.local/bin/fasd
$(HOME)/.local/bin/fasd:
	@bash ./install/run-helper git-clone "https://github.com/clvv/fasd.git" "/tmp/fasd" --depth 1
	PREFIX="$(HOME)/.local" make -C "/tmp/fasd" install

pip3: flags/pip3

i3: flags/i3
nvim: flags/neovim
neovim: flags/neovim

# Programming Languages
node: flags/node
rust: flags/rust
java: flags/java
maven: flags/maven
gradle: flags/gradle

docker: flags/docker flags/docker-credential-ecr-login docker-compose
docker-compose: flags/docker-compose
docker-compose-update: update.flags/docker-compose flags/docker-compose

# Tools
awscli: flags/awscli
awscli-update: update.flags/awscli flags/awscli
kdeconnect: flags/kdeconnect
postman: flags/postman
etcher: flags/etcher
onedrive: flags/onedrive
onedrive-update: update.flags/onedrive flags/onedrive

# System Configuration
gpg: flags/gpg
polybar: flags/polybar
gestures: flags/gestures
hall-monitor: flags/hall-monitor
libinput: flags/libinput
redshift: flags/redshift
intel-backlight: flags/intel-backlight
fonts-hack: flags/fonts-hack
grub-theme: flags/grub-theme

# Fixes for firefox when using dark themes and for scrolling using a touchscreen
# Theme fix from https://wiki.archlinux.org/index.php/Firefox#Unreadable_input_fields_with_dark_GTK.2B_themes
# Scrolling fix from https://wiki.gentoo.org/wiki/Firefox#Xinput2_scrolling
firefox-fix:
	sudo sed -i 's/Exec=.*firefox/Exec=env MOZ_USE_XINPUT2=1 GTK_THEME=Adwaita:light firefox/' /usr/share/applications/firefox.desktop

tridactyl:
	wget --directory-prefix="/tmp" --timestamping "https://tridactyl.cmcaine.co.uk/betas/nonewtab/tridactyl_no_new_tab_beta-latest.xpi"
	firefox "/tmp/tridactyl_no_new_tab_beta-latest.xpi"
	mkdir -p "$(XDG_CONFIG_HOME)/tridactyl"
	@bash ./install/run-helper link tridactylrc "$(XDG_CONFIG_HOME)/tridactyl/tridactylrc"

pgcli: pip3 apt.python3-dev apt.libpq-dev
	pip3 install --user --upgrade pgcli
	mkdir --parents "$(XDG_CONFIG_HOME)/pgcli"
	@bash ./install/run-helper link pgcli $(XDG_CONFIG_HOME)/pgcli/config
	-ln -sf "$$(which pgcli)" "flags"

bindkeys: apt.xbindkeys apt.xdotool
	@bash ./install/run-helper link xbindkeysrc $(HOME)/.xbindkeysrc
	xbindkeys

tmux: apt.libevent-dev apt.libncurses-dev apt.xclip
	curl --location --silent --show-error https://github.com/tmux/tmux/releases/download/$(version)/tmux-$(version).tar.gz | tar -xz -C /tmp
	cd /tmp/tmux-$(version) && ./configure && make
	cd /tmp/tmux-$(version) && sudo make install
	tic -o ~/.terminfo install/tmux-256color.terminfo
	@bash ./install/run-helper link tmux.conf $(HOME)/.tmux.conf

alacritty: flags/alacritty-src
stterm: flags/stterm

flags/neovim: pip3
	sudo add-apt-repository --update --yes ppa:neovim-ppa/stable
	@bash ./install/run-helper installif neovim
	pip3 install --user --upgrade pynvim
	mkdir -p ~/.config/nvim
	@bash ./install/run-helper link vimrc $(HOME)/.config/nvim/init.vim
	@bash ./install/run-helper link vim/syntax $(HOME)/.config/nvim/syntax
	curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
	nvim +PlugUpdate +qa
	touch flags/neovim

npm: npm-install npm-update

npm-install: node
	npm install --global $(packages)

npm-update: node
	npm install --global npm@latest
	npm install --global $(shell npm ls --global | tail --lines=+2 | sed --regexp-extended -e 's/(├|└)─+ //' -e '/->/d' -e 's/@[0-9]+.*/@latest/' | tr '\n' ' ')

jetbrains:
	./jetbrains.sh

apt.%:
	@bash ./install/run-helper installif $*

update.flags/%:
	@rm flags/$* || true


flags/pip3: apt.python3-distutils
	curl --location --silent --show-error https://bootstrap.pypa.io/get-pip.py -o /tmp/get-pip.py
	python3 /tmp/get-pip.py --user
	ln -sf "$(HOME)/.local/bin/pip3" "flags"

flags/i3: apt.i3 apt.i3lock apt.xautolock apt.rofi fonts-hack
	mkdir --parents "$(XDG_CONFIG_HOME)/i3"
	mkdir --parents "$(XDG_CONFIG_HOME)/i3status"
	mkdir --parents "$(XDG_CONFIG_HOME)/rofi"
	@bash ./install/run-helper link "i3.conf" "$(XDG_CONFIG_HOME)/i3/config"
	@bash ./install/run-helper link "i3status.conf" "$(XDG_CONFIG_HOME)/i3status/config"
	@bash ./install/run-helper link "rofi.rasi" "$(XDG_CONFIG_HOME)/rofi/config.rasi"
	ln -sf "$(XDG_CONFIG_HOME)/i3/config" "flags/i3"

flags/polybar: repository = https://github.com/jaagr/polybar
flags/polybar:
	sudo apt install --no-install-recommends \
	  libuv1-dev \
	  libcairo2-dev \
	  libxcb1-dev \
	  libxcb-util0-dev \
	  libxcb-randr0-dev \
	  libxcb-composite0-dev \
	  python3-xcbgen \
	  xcb-proto \
	  libxcb-image0-dev \
	  libxcb-ewmh-dev \
	  libxcb-icccm4-dev \
	  libxcb-cursor-dev \
	  libjsoncpp-dev \
	  libpulse-dev \
	  libnl-genl-3-dev
	@# get latest tagged version
	$(eval version = $(shell git ls-remote --tags --refs $(repository) | awk -F"[\t/]" 'END{print $$NF}'))
	$(eval file = polybar-$(version).tar.gz)
	wget --directory-prefix="/tmp" --timestamping "$(repository)/releases/download/$(version)/$(file)"
	tar --directory "/tmp" --extract --gzip --file "/tmp/$(file)"
	mkdir --parents "/tmp/polybar-$(version)/build"
	cd "/tmp/polybar-$(version)/build" && cmake ..
	make -C "/tmp/polybar-$(version)/build" -j$$(nproc)
	sudo make -C "/tmp/polybar-$(version)/build" install
	mkdir --parents "$(XDG_CONFIG_HOME)/polybar"
	@bash ./install/run-helper link "polybar.ini" "$(XDG_CONFIG_HOME)/polybar/config.ini"
	@bash ./install/run-helper link "install/launch-polybar.sh" "$(XDG_CONFIG_HOME)/polybar/launch.sh"
	-ln -sf "$$(which polybar)" "flags"

flags/node: flags/sysctl-inotify
	curl --location https://git.io/n-install | N_PREFIX=$(XDG_DATA_HOME)/nodejs bash -s -- -n
	@bash ./install/run-helper link "tern-project" "$(HOME)/.tern-project"
	ln -sf $(XDG_DATA_HOME)/nodejs/bin/node flags/node

flags/rust:
	$(eval tmp = $(shell mktemp --dry-run --tmpdir="/tmp" rustup-init-XXX))
	wget -O $(tmp) https://static.rust-lang.org/rustup/dist/x86_64-unknown-linux-gnu/rustup-init
	chmod a+x $(tmp)
	exec $(tmp) --verbose --no-modify-path -y
	-rm $(tmp)
	ln -sf $(HOME)/.cargo/bin/rustc flags/rust

flags/java:
	@bash ./install/run-helper installif default-jdk
	ln -sf "$$(update-alternatives --list java)" flags/java

flags/maven: flags/java flags/opt-dir
	# TODO verify signature of download
	wget -O /tmp/maven.tar.gz http://www-us.apache.org/dist/maven/maven-3/$(version)/binaries/apache-maven-$(version)-bin.tar.gz
	tar -xzf /tmp/maven.tar.gz --directory /opt
	mv /opt/apache-maven-$(version) /opt/maven
	ln -sf /opt/maven flags

flags/gradle: flags/java flags/opt-dir
	$(eval tmp = $(shell mktemp --dry-run --tmpdir="/tmp" gradle-XXX.zip))
	wget -O "$(tmp)" "https://services.gradle.org/distributions/gradle-$(version)-bin.zip"
	unzip -d "/opt" "$(tmp)"
	mv "/opt/gradle-$(version)" "/opt/gradle"
	-rm "$(tmp)"
	ln -sf /opt/gradle flags

# all versions after don't have prebuilt binaries
flags/alacritty: version = v0.4.3
flags/alacritty: fonts-hack
	$(eval file = Alacritty-$(version)-ubuntu_18_04_amd64.deb)
	wget --directory-prefix="/tmp" --timestamping "https://github.com/alacritty/alacritty/releases/download/$(version)/$(file)"
	sudo apt install "/tmp/$(file)"
	mkdir -p "$(XDG_CONFIG_HOME)/alacritty"
	@bash ./install/run-helper link "alacritty.yml" "$(XDG_CONFIG_HOME)/alacritty/alacritty.yml"
	ln -sf "/usr/bin/alacritty" "flags"

flags/alacritty-src: version = v0.7.2
flags/alacritty-src: rust fonts-hack apt.cmake apt.libfreetype6-dev apt.libfontconfig1-dev apt.libxcb-xfixes0-dev apt.xclip
	@bash ./install/run-helper git-clone "https://github.com/alacritty/alacritty" "/tmp/alacritty"
	cd /tmp/alacritty && git checkout "$(version)"
	rustup override set stable
	rustup update stable
	cd "/tmp/alacritty" && cargo build --release
	sudo mv "/tmp/alacritty/target/release/alacritty" "/usr/local/bin"
	sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator /usr/local/bin/alacritty 50
	# Desktop Entry
	sudo cp "/tmp/alacritty/extra/logo/alacritty-term.svg" "/usr/share/pixmaps/Alacritty.svg"
	sudo desktop-file-install "/tmp/alacritty/extra/linux/Alacritty.desktop"
	sudo update-desktop-database
	# Man Page
	sudo mkdir -p "/usr/local/share/man/man1"
	gzip -c "/tmp/alacritty/extra/alacritty.man" | sudo tee "/usr/local/share/man/man1/alacritty.1.gz" > /dev/null
	# Cleanup
	-rm -rf "/tmp/alacritty"
	mkdir -p "$(XDG_CONFIG_HOME)/alacritty"
	@bash ./install/run-helper link "alacritty.yml" "$(XDG_CONFIG_HOME)/alacritty/alacritty.yml"
	ln -sf "/usr/local/bin/alacritty" "flags/alacritty-src"

flags/stterm: apt.libx11-dev apt.libxft-dev
	wget --directory-prefix="/tmp" --timestamping https://dl.suckless.org/st/st-$(version).tar.gz
	wget --directory-prefix="/tmp" --timestamping https://dl.suckless.org/st/sha256sums.txt
	cd /tmp && sha256sum --ignore-missing --check sha256sums.txt
	tar -xzf /tmp/st-$(version).tar.gz -C /tmp
	-rm /tmp/st-$(version).tar.gz
	-rm /tmp/sha256sums.txt
	sudo make -C /tmp/st-$(version) clean install
	-rm -rf /tmp/st-$(version)
	ln -sf /usr/local/bin/st flags/stterm

flags/docker:
	sudo apt-key add install/docker.gpg
	sudo add-apt-repository --update "deb [arch=amd64] https://download.docker.com/linux/ubuntu $$(lsb_release -cs) stable"
	@bash ./install/run-helper installif docker-ce
	@# force returns success if group exists already
	sudo groupadd --force docker
	sudo usermod --append --groups docker $(USER)
	ln -sf "$$(which docker)" flags/docker

flags/docker-credential-ecr-login:
	@bash ./install/run-helper git-clone "https://github.com/awslabs/amazon-ecr-credential-helper" "/tmp/amazon-ecr-credential-helper"
	make -C "/tmp/amazon-ecr-credential-helper" docker
	cp "/tmp/amazon-ecr-credential-helper/bin/local/docker-credential-ecr-login" "$(HOME)/bin"
	mkdir -p "$(HOME)/.docker"
	@bash ./install/run-helper link "install/docker-config.json" "$(HOME)/.docker/config.json"
	ln -sf "$(HOME)/bin/docker-credential-ecr-login" "flags"

flags/docker-compose:
	curl --location --silent --show-error https://github.com/docker/compose/releases/download/$(compose-version)/docker-compose-Linux-x86_64 -o $(HOME)/bin/docker-compose
	chmod +x $(HOME)/bin/docker-compose
	ln -sf $(HOME)/bin/docker-compose flags

flags/awscli:
	wget --directory-prefix="/tmp" --timestamping "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip"
	unzip -u -d "/tmp" "/tmp/awscli-exe-linux-x86_64.zip"
	/tmp/aws/install --update --install-dir "$(XDG_DATA_HOME)/awscli" --bin-dir "$(HOME)/.local/bin"
	-ln -sf "$$(which aws)" "flags/awscli"

flags/kdeconnect:
	@bash ./install/run-helper installif kdeconnect plasma-browser-integration
	sudo ufw allow from 192.168.0.0/16 to any port 1714:1764 proto tcp
	sudo ufw allow from 192.168.0.0/16 to any port 1714:1764 proto udp
	sudo ufw reload
	@sudo bash ./install/run-helper link "install/kdeconnect.service" "/etc/systemd/user/kdeconnect.service"
	systemctl --user enable kdeconnect.service
	systemctl --user start kdeconnect.service
	-ln -sf "$$(which kdeconnect-cli)" "flags/kdeconnect"


flags/postman: opt-dir
	wget --output-document "/tmp/postman.tar.gz" https://dl.pstmn.io/download/latest/linux64
	tar --directory "/opt" --extract --gzip --file  "/tmp/postman.tar.gz"
	sudo ln -sf "/opt/Postman/app/Postman" "/usr/local/bin/postman"
	rm -f "/tmp/postman.tar.gz"
	ln -sf "/usr/local/bin/postman" "flags"

flags/etcher: repository = balena-io/etcher
flags/etcher: apt.jq
	@# get latest tagged version
	$(eval version = $(shell curl --silent "https://api.github.com/repos/$(repository)/releases/latest" | jq -r .tag_name))
	$(eval file = balenaEtcher-$(shell echo $(version) | sed "s/v//" )-x64.AppImage)
	wget --directory-prefix="/tmp" --timestamping "https://github.com/$(repository)/releases/download/$(version)/$(file)"
	mv "/tmp/$(file)" "$(HOME)/bin/etcher"
	chmod a+x "$(HOME)/bin/etcher"
	ln -sf "$(HOME)/bin/etcher" "flags"

flags/onedrive: version = v2.4.25
flags/onedrive:
	@bash ./install/run-helper installif build-essential libnotify-dev libcurl4-openssl-dev libsqlite3-dev pkg-config git curl
	wget --directory-prefix="/tmp" --timestamping "https://dlang.org/install.sh"
	chmod a+x /tmp/install.sh
	/tmp/install.sh install dmd
	@bash ./install/run-helper git-clone "https://github.com/abraunegg/onedrive.git" "/tmp/onedrive"
	cd "/tmp/onedrive" && git checkout "$(version)"
	source "$$(/tmp/install.sh dmd -a)" && cd /tmp/onedrive && ./configure --enable-notifications
	source "$$(/tmp/install.sh dmd -a)" && make -C /tmp/onedrive
	sudo make -C /tmp/onedrive install
	mkdir -p "$(XDG_CONFIG_HOME)/onedrive"
	@bash ./install/run-helper link "onedrive" "$(XDG_CONFIG_HOME)/onedrive/config"
	@bash ./install/run-helper link "sync_list" "$(XDG_CONFIG_HOME)/onedrive/sync_list"
	-/tmp/install.sh uninstall dmd
	-rm -rf "$(HOME)/dlang"
	onedrive --display-sync-status
	systemctl --user enable onedrive
	systemctl --user start onedrive
	-ln -sf "$$(which onedrive)" "flags"

flags/gpg: apt.scdaemon
	@sudo bash ./install/run-helper link "install/70-yubikey.rules" "/etc/udev/rules.d/70-yubikey.rules"
	mkdir --parents "$(HOME)/.gnupg"
	chmod 700 "$(HOME)/.gnupg"
	@sudo bash ./install/run-helper link "gpg.conf" "$(HOME)/.gnupg/gpg.conf"
	@sudo bash ./install/run-helper link "gpg-agent.conf" "$(HOME)/.gnupg/gpg-agent.conf"

flags/gestures: apt.libinput-tools
	@# Only known to work with libinput on Ubuntu 18.04
	@bash ./install/run-helper git-clone \
	  "https://github.com/bulletmark/libinput-gestures.git" \
	  "/tmp/libinput-gestures"
	sudo usermod --append --groups input "$(USER)"
	sudo make -C "/tmp/libinput-gestures" install
	@bash ./install/run-helper link "libinput-gestures.conf" "$(XDG_CONFIG_HOME)/libinput-gestures.conf"
	ln -sf "/usr/bin/libinput-gestures-setup" "flags/gestures"

flags/hall-monitor: apt.jq apt.lxrandr apt.x11-xserver-utils
	mkdir --parents "$(XDG_CONFIG_HOME)/hall-monitor"
	@sudo bash ./install/run-helper link "hall-monitor/hall-monitor" "/usr/local/bin/hall-monitor"
	@sudo bash ./install/run-helper link "hall-monitor/95-hall-monitor.rules" "/etc/udev/rules.d/95-hall-monitor.rules"
	@sudo bash ./install/run-helper link "hall-monitor/hall-monitor.service" "/etc/systemd/user/hall-monitor.service"
	systemctl --user enable hall-monitor.service
	systemctl --user start hall-monitor.service
	ln -sf "/usr/local/bin/hall-monitor" "flags"

flags/sysctl-inotify:
	@sudo bash ./install/run-helper link "install/60-inotify-watches.conf" "/etc/sysctl.d/60-inotify-watches.conf"
	sudo systemctl restart procps
	-ln -sf "/etc/sysctl.d/60-inotify-watches.conf" "flags/sysctl-inotify"

flags/libinput:
	sudo mkdir --parents "/etc/X11/xorg.conf.d"
	@sudo bash ./install/run-helper link "40-libinput.conf" "/etc/X11/xorg.conf.d/40-libinput.conf"
	ln -sf "/etc/X11/xorg.conf.d/40-libinput.conf" "flags/libinput"

flags/redshift:
	sudo apt-get install --no-install-recommends redshift-gtk
	command -v debfoster && sudo debfoster redshift-gtk
	@sudo bash ./install/run-helper link "redshift.conf" "$(XDG_CONFIG_HOME)/redshift.conf"
	-ln -sf "$$(which redshift)" "flags"

flags/intel-backlight: apt.xserver-xorg-video-intel apt.xbacklight
	@sudo bash ./install/run-helper link "install/20-intel-backlight.conf" "/etc/X11/xorg.conf.d/20-intel-backlight.conf"
	-ln -sf "/etc/X11/xorg.conf.d/20-intel-backlight.conf" "flags/intel-backlight"

flags/fonts-hack: repository = https://github.com/source-foundry/Hack
flags/fonts-hack:
	@# get latest tagged version
	$(eval version = $(shell git ls-remote --tags --refs $(repository) | awk -F"[\t/]" 'END{print $$NF}'))
	$(eval file = Hack-$(version)-ttf.zip)
	wget --directory-prefix="/tmp" --timestamping "$(repository)/releases/download/$(version)/$(file)"
	wget --directory-prefix="/tmp" --timestamping "https://raw.githubusercontent.com/source-foundry/Hack/$(version)/config/fontconfig/45-Hack.conf"
	unzip "/tmp/$(file)" -d "/tmp/hack"
	sudo mv /tmp/hack/ttf/* "/usr/local/share/fonts"
	sudo mv "/tmp/45-Hack.conf" "/etc/fonts/conf.d"
	fc-cache -f -v
	-ln -sf "$$(fc-list | grep Hack-Regular | awk -F : '{print $$1}')" "flags/fonts-hack"

flags/grub-theme:
	@bash ./install/run-helper git-clone "git@github.com:vinceliuice/grub2-themes.git" "/tmp/grub2-themes"
	sudo /tmp/grub2-themes/install.sh --vimix --4k
	-ln -sf "/usr/share/grub/themes/Vimix/theme.txt" "flags/grub-theme"

opt-dir: flags/opt-dir
flags/opt-dir:
	sudo groupadd optgroup
	sudo usermod -aG optgroup gurpreet
	sudo usermod -aG optgroup root
	sudo chown -R root:optgroup /opt
	sudo chmod -R g+rw /opt
	ln -sf /opt flags/opt-dir
