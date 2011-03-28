# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

inherit vim-plugin git

DESCRIPTION="Package manager for Vim"
HOMEPAGE="http://github.com/MarcWeber/vim-addon-manager"
EGIT_REPO_URI="git://github.com/MarcWeber/vim-addon-manager.git"
SRC_URI=""
USE="git subversion mercurial"
IUSE="git subversion mercurial"
RDEPEND="
	git? ( dev-vcs/git )
	subversion? ( dev-vcs/subversion )
	mercurial? ( dev-vcs/mercurial )
"

src_prepare() {
	rm -rf .git *.sh
}

src_install() {
	dodoc autoload/sample_vimrc_for_new_users.vim
	rm -f autoload/sample_vimrc_for_new_users.vim
	vim-plugin_src_install
}

