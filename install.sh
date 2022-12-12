echo "Checking for git..."
git --version 2>/dev/null \
  || sudo pacman -Syu --noconfirm git 2>/dev/null \
  || sudo apt install --yes git 2>/dev/null \
  || git --version

echo "Creating repos dir..."
REPOS="${HOME}/repos"
cd "${REPOS}"
mkdir -p github.com/attilaolah
rm -f my
ln -s github.com/attilaolah my

echo "Cloning attilaolah/dotfiles..."
mkdir -p "${REPOS}/github.com/attilaolah"
cd "${REPOS}/my"
[[ -d dotfiles ]] || git clone https://github.com/attilaolah/dotfiles
cd dotfiles
git remote set-url origin git@github.com:attilaolah/dotfiles
DOTFILES="$(pwd)"

echo "Linking files..."
files=(\
  .config/fish/config.fish \
  .config/fish/functions/fish_prompt.fish \
  .config/nvim/init.vim \
  .gitconfig \
  .gitignore \
  .hgrc \
  .profile \
  .tmux.conf \
  .vimrc \
  .zshrc \
)
for f in ${files[@]}; do
  hf="${HOME}/${f}"
  rm -f "${hf}"
  mkdir -p "$(dirname "${hf}")"
  ln -s "${DOTFILES}/${f}" "${hf}"
done

echo "Installing locales..."
sudo truncate --size=0 /etc/locale.gen
cat "${DOTFILES}/etc/locale.gen" | sudo tee /etc/locale.gen
sudo locale-gen

echo "Checking for zsh..."
zsh --version 2>/dev/null \
  || sudo pacman -Syu --noconfirm zsh 2>/dev/null \
  || sudo apt install --yes zsh 2>/dev/null \
  || zsh --version
rehash 2>/dev/null || true
sudo chsh -s "$(which zsh)" "${USER}"

echo "Checking for fish..."
fish --version 2>/dev/null \
  || sudo pacman -Syu --noconfirm fish 2>/dev/null \
  || sudo apt install --yes fish 2>/dev/null \
  || fish --version
rehash 2>/dev/null || true

echo "Downloading https://github.com/junegunn/vim-plug..."
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Before starting vim, make sure to move out of the repo.
# This avoids recursive lookups for ".vimrc" causing an infinite loop.
cd

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

echo "Installing vim/nvim plugins..."
vim +'PlugInstall --sync' +qa

echo "Checking for tmux..."
tmux --version 2>/dev/null \
  || sudo pacman -Syu --noconfirm tmux 2>/dev/null \
  || sudo apt install --yes tmux 2>/dev/null \
  || tmux --version
rehash 2>/dev/null || true
echo "Done!"
