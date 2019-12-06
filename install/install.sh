# link the dotfiles
unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)     machine=Linux
                alias_file=~/.bashrc
                bash_profile_file=~/.bashrc
                ;;
    Darwin*)    machine=Mac
                alias_file=~/.aliases
                bash_profile_file=~/.bash_profile
                ;;
    CYGWIN*)    machine=Cygwin;;
    MINGW*)     machine=MinGw;;
    *)          machine="UNKNOWN:${unameOut}"
esac

echo "Setting shortcuts for dotfiles"
ln -s ~/dotfiles/gitconfig ~/.gitconfig
ln -s ~/dotfiles/vim/vimrc ~/.vimrc
ln -s ~/dotfiles/tmux.conf ~/.tmux.conf
read -p "Press any key to continue... " -n1 -s

echo "Installing packages..."
if [ ${machine} == 'Mac' ] ; then
  echo "Install Homebrew"
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  ln -s ~/dotfiles/Brewfile ~/Brewfile
  brew bundle
fi

if [ ${machine} == 'Linux' ] ; then
  < ~/dotfiles/ubuntu_packages xargs sudo apt-get install -y
fi

read -p "Press any key to continue... " -n1 -s

# Install Vim plugin manager
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Add aliases
if ! grep -q -E '^alias ll=.*$' ${alias_file}; then
    echo "Adding ll alias"
    echo "# List all files colorized in long format" >> ${alias_file}
    echo 'alias ll="ls -lah"' >> ${alias_file}
fi

if ! grep -q -E '^set -o vi$' ${bash_profile_file}; then
    echo "Setting VI bindings in bash"
    echo 'set -o vi' >> ${bash_profile_file}
fi
