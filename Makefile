
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

zsh-theme: flags/spaceship.zsh-theme

zsh-theme-update: update.flags/spaceship.zsh-theme flags/spaceship.zsh-theme

pgcli: apt.python-pip apt.python-dev apt.libpq-dev apt.libevent-dev
	sudo pip install --upgrade pgcli

tmux: apt.libevent-dev apt.libncurses-dev apt.xclip
	curl --location --silent --show-error https://github.com/tmux/tmux/releases/download/$(version)/tmux-$(version).tar.gz | tar -xz -C /tmp
	cd /tmp/tmux-$(version) && ./configure && make
	cd /tmp/tmux-$(version) && sudo make install
	tic -o ~/.terminfo install/tmux-256color.terminfo
	bash ./install/run-helper link tmux.conf $(HOME)/.tmux.conf

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
