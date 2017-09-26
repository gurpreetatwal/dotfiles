
npm-%: packages = bower browser-sync bunyan gulp eslint_d nodemon

install:
	./install.sh

zsh:
	echo "installing zsh"

zsh-theme-spaceship: zsh
	echo "intalling theme"

npm: npm-install npm-update

npm-install:
	sudo npm install --global $(packages)

npm-update:
	sudo npm install --global npm
	sudo npm update --global $(packages)

jetbrains:
	./jetbrains.sh

opt-dir: flags/opt-dir
flags/opt-dir:
	sudo groupadd optgroup
	sudo usermod -aG optgroup gurpreet
	sudo usermod -aG optgroup root
	sudo chown -R root:optgroup /opt
	sudo chmod -R g+rw /opt
	touch flags/opt-dir
