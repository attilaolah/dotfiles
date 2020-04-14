echo "Checking for git..."
git --version 2>/dev/null \
  || sudo pacman -Syu --noconfirm git 2>/dev/null \
  || sudo apt install --yes git 2>/dev/null \
  || git --version

mkdir -p "${HOME}/third_party/github.com/attilaolah"
cd "${HOME}/third_party/github.com/attilaolah"
rm -rf dotfiles
git clone https://github.com/attilaolah/dotfiles
cd

for file in .gitconfig .hgrc .profile .tmux.conf .vimrc .zshrc; do
  rm -f "${file}"
  ln -s "third_party/github.com/attilaolah/dotfiles/${file}"
done
mkdir -p .config/nvim
cd .config/nvim
ln -s ../../third_party/github.com/attilaolah/dotfiles/.config/nvim/init.vim
cd

echo "Checking for zsh..."
zsh --version 2>/dev/null \
  || sudo pacman -Syu --noconfirm zsh 2>/dev/null \
  || sudo apt install --yes zsh 2>/dev/null \
  || zsh --version
rehash 2>/dev/null || true
sudo chsh -s "$(which zsh)" "${USER}"


echo "Downloading https://github.com/junegunn/vim-plug..."
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

echo "Checking for vim..."
vim --version 2>/dev/null \
  || sudo pacman -Syu --noconfirm vim 2>/dev/null \
  || sudo apt install --yes vim 2>/dev/null \
  || vim --version
rehash 2>/dev/null || true

echo "Checking for nvim..."
nvim --version 2>/dev/null \
  || sudo pacman -Syu --noconfirm neovim 2>/dev/null \
  || sudo apt install --yes neovim 2>/dev/null \
  || nvim --version
rehash 2>/dev/null || true

vim +'PlugInstall --sync' +qa

echo "Checking for tmux..."
tmux --version 2>/dev/null \
  || sudo pacman -Syu --noconfirm tmux 2>/dev/null \
  || sudo apt install --yes tmux 2>/dev/null \
  || tmux --version
rehash 2>/dev/null || true
