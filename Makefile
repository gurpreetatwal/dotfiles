
tmux: version = 2.6
npm-%: packages = bower browser-sync bunyan gulp eslint_d nodemon

.PHONY:
	install
	pgcli
	npm
	npm-install
	npm-update

install:
	./install.sh

zsh:
	echo "installing zsh"

pip2: flags/pip2
pip3: flags/pip3

nvim: flags/neovim
neovim: flags/neovim

zsh-theme: flags/spaceship.zsh-theme

zsh-theme-update: update.flags/spaceship.zsh-theme flags/spaceship.zsh-theme

pgcli: pip2 apt.libpq-dev apt.libevent-dev
	sudo pip install --upgrade pgcli

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

npm-install:
	sudo npm install --global $(packages)

npm-update:
	sudo npm install --global npm
	sudo npm update --global $(packages)

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
