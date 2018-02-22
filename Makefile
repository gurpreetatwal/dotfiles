
# default XDG_DATA_HOME to ~/.local/share and XDG_CONFIG_HOME to ~/.config if not set
# @see https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html#basics
XDG_DATA_HOME ?= $(HOME)/.local/share
XDG_CONFIG_HOME ?= $(HOME)/.config

tmux: version ?= 2.6
maven: version ?= 3.5.2
npm-%: packages = bower browser-sync bunyan gulp-cli eslint_d nodemon

.PHONY:
	install
	pgcli
	npm
	npm-install
	npm-update

install:
	./install.sh

basic: apt.tree apt.silversearcher-ag apt.git
	mkdir -p $(HOME)/bin
	mkdir -p $(HOME)/temp
	test -d $(HOME)/scripts/.git || git clone https://github.com/gurpreetatwal/scripts.git  $(HOME)/scripts
	bash ./install/run-helper link "agignore" "$(HOME)/.agignore"
	bash ./install/run-helper link "gitconfig" "$(HOME)/.gitconfig"
	bash ./install/run-helper link "gitignore.global" "$(HOME)/.gitignore.global"
	bash ./install/run-helper link "shell/profile" "$(HOME)/.bash_profile"

zsh: apt.zsh
	sudo usermod --shell "$$(which zsh)" "$$(whoami)"
	bash ./install/run-helper link "shell/zshrc" "$(HOME)/.zshrc"
	bash ./install/run-helper link "shell/profile" "$(HOME)/.zprofile"

pip2: flags/pip2
pip3: flags/pip3

nvim: flags/neovim
neovim: flags/neovim

# Programming Languages
node: flags/node
java: flags/java
maven: flags/maven

zsh-theme: flags/spaceship.zsh-theme

zsh-theme-update: update.flags/spaceship.zsh-theme flags/spaceship.zsh-theme

# Fix for firefox when using dark themes
# Adapted from https://wiki.archlinux.org/index.php/Firefox#Unreadable_input_fields_with_dark_GTK.2B_themes
firefox-fix:
	sudo sed -i 's/Exec=firefox/Exec=env GTK_THEME=Adwaita:light firefox/' /usr/share/applications/firefox.desktop

pgcli: pip2 apt.libpq-dev apt.libevent-dev
	pip install --user --upgrade pgcli
	bash ./install/run-helper link pgcli $(XDG_CONFIG_HOME)/pgcli/config

bindkeys: apt.xbindkeys apt.xdotool
	bash ./install/run-helper link xbindkeysrc $(HOME)/.xbindkeysrc
	xbindkeys

tmux: apt.libevent-dev apt.libncurses-dev apt.xclip
	curl --location --silent --show-error https://github.com/tmux/tmux/releases/download/$(version)/tmux-$(version).tar.gz | tar -xz -C /tmp
	cd /tmp/tmux-$(version) && ./configure && make
	cd /tmp/tmux-$(version) && sudo make install
	tic -o ~/.terminfo install/tmux-256color.terminfo
	bash ./install/run-helper link tmux.conf $(HOME)/.tmux.conf

flags/neovim: pip2 pip3
	sudo add-apt-repository ppa:neovim-ppa/stable
	sudo apt-get update
	sudo apt-get install neovim
	pip2 install --user --upgrade neovim
	pip3 install --user --upgrade neovim
	mkdir -p ~/.config/nvim
	bash ./install/run-helper link vimrc $(HOME)/.config/nvim/init.vim
	curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
	nvim +PlugUpdate +qa
	touch flags/neovim

npm: npm-install npm-update

npm-install: node
	npm install --global $(packages)

npm-update: node
	npm install --global npm
	npm update --global $(packages)

jetbrains:
	./jetbrains.sh

apt.%:
	bash ./install/run-helper installif $*

update.flags/%:
	@rm flags/$* || true

flags/pip2: apt.python-dev apt.python-pip
	sudo -H pip2 install --upgrade pip
	pip2 install --user wheel
	pip2 install --user setuptools
	touch flags/pip2

flags/pip3: apt.python3-dev apt.python3-pip
	sudo -H pip3 install --upgrade pip
	pip3 install --user wheel
	pip3 install --user setuptools
	touch flags/pip3

flags/node:
	curl --location https://git.io/n-install | N_PREFIX=$(XDG_DATA_HOME)/nodejs bash -s -- -n
	ln -s $(XDG_DATA_HOME)/nodejs/bin/node flags/node

flags/java:
	sudo apt-get remove --purge 'openjdk8*'
	sudo add-apt-repository --yes ppa:webupd8team/java
	sudo apt-get update
	echo "oracle-java9-installer shared/accepted-oracle-license-v1-1 select true" | sudo debconf-set-selections
	sudo apt-get install oracle-java9-installer oracle-java9-set-default
	ln -s "$$(update-alternatives --list java)" flags/java

flags/maven: java opt-dir
	# TODO verify signature of download
	wget -O /tmp/maven.tar.gz http://www-us.apache.org/dist/maven/maven-3/$(version)/binaries/apache-maven-$(version)-bin.tar.gz
	tar -xzf /tmp/maven.tar.gz --directory /opt
	mv /opt/apache-maven-$(version) /opt/maven
	ln -s /opt/maven flags/maven

opt-dir: flags/opt-dir
flags/opt-dir:
	sudo groupadd optgroup
	sudo usermod -aG optgroup gurpreet
	sudo usermod -aG optgroup root
	sudo chown -R root:optgroup /opt
	sudo chmod -R g+rw /opt
	touch flags/opt-dir

flags/spaceship.zsh-theme:
	curl -LSsfo ~/.oh-my-zsh/custom/themes/spaceship.zsh-theme --create-dirs https://raw.githubusercontent.com/denysdovhan/spaceship-zsh-theme/master/spaceship.zsh
	ln -s ~/.oh-my-zsh/custom/themes/spaceship.zsh-theme flags
