echo "Checking for git..."
git --version 2>/dev/null \
  || sudo pacman -Syu --noconfirm git 2>/dev/null \
  || sudo apt install --yes git 2>/dev/null \
  || git --version
echo "\n"

echo "Cloning attilaolah/dotfiles..."
mkdir -p "${HOME}/third_party/github.com/attilaolah"
cd "${HOME}/third_party/github.com/attilaolah"
rm -rf dotfiles
git clone https://github.com/attilaolah/dotfiles
cd dotfiles
git remote set-url origin git@github.com:attilaolah/dotfiles
cd
echo "\n"

echo "Linking files..."
for file in .gitconfig .gitignore .hgrc .profile .tmux.conf .vimrc .zshrc; do
  rm -f "${file}"
  ln -s "third_party/github.com/attilaolah/dotfiles/${file}"
done
mkdir -p .config/nvim
cd .config/nvim
ln -s ../../third_party/github.com/attilaolah/dotfiles/.config/nvim/init.vim
cd
echo "\n"

echo "Installing locales..."
sudo truncate --size=0 /etc/locale.gen
cat third_party/github.com/attilaolah/dotfiles/etc/locale.gen | sudo tee /etc/locale.gen
sudo locale-gen
echo "\n"

echo "Checking for zsh..."
zsh --version 2>/dev/null \
  || sudo pacman -Syu --noconfirm zsh 2>/dev/null \
  || sudo apt install --yes zsh 2>/dev/null \
  || zsh --version
rehash 2>/dev/null || true
sudo chsh -s "$(which zsh)" "${USER}"
echo "\n"


echo "Downloading https://github.com/junegunn/vim-plug..."
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
echo "\n"

echo "Checking for vim..."
vim --version 2>/dev/null \
  || sudo pacman -Syu --noconfirm vim 2>/dev/null \
  || sudo apt install --yes vim 2>/dev/null \
  || vim --version
rehash 2>/dev/null || true
echo "\n"

echo "Checking for nvim..."
nvim --version 2>/dev/null \
  || sudo pacman -Syu --noconfirm neovim 2>/dev/null \
  || sudo apt install --yes neovim 2>/dev/null \
  || nvim --version
rehash 2>/dev/null || true
echo "\n"

echo "Installing vim/nvim plugins..."
vim +'PlugInstall --sync' +qa
echo "\n"

echo "Checking for tmux..."
tmux --version 2>/dev/null \
  || sudo pacman -Syu --noconfirm tmux 2>/dev/null \
  || sudo apt install --yes tmux 2>/dev/null \
  || tmux --version
rehash 2>/dev/null || true
echo "Done!"
