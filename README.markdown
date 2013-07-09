# Vim configuration

Install this configuration like this:

	cd
	git clone https://github.com/attilaolah/dotvim .vim
	(cd .vim && git submodule init)
	ln -s .vim/vimrc .vimrc

To make the required binaries available, add this line to `~/.bashrc`:

	source "$HOME/.vim/bashrc"

To update submodules in the repo, run:

	git submodule foreach git submodule init
	git submodule foreach git submodule update
	git submodule foreach git pull origin master

To install dependencies, run:

	sudo emerge --ask --tree \
		dev-python/flake8 \
		dev-python/jedi \
		dev-ruby/sass \
		net-libs/nodejs

Flake8 will pull in PEP8 and PyFlakes. Node.js is required by less.js.
