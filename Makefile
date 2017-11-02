
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

zsh-theme-spaceship: zsh
	echo "intalling theme"

pgcli: apt.python-pip apt.python-dev apt.libpq-dev apt.libevent-dev
	sudo pip install --upgrade pgcli

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

opt-dir: flags/opt-dir
flags/opt-dir:
	sudo groupadd optgroup
	sudo usermod -aG optgroup gurpreet
	sudo usermod -aG optgroup root
	sudo chown -R root:optgroup /opt
	sudo chmod -R g+rw /opt
	touch flags/opt-dir
