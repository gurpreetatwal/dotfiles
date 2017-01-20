
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
