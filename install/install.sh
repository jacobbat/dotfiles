#!/bin/bash

# Set OS specific variables
set_os_vars() {
  unameOut="$(uname -s)"
  case "${unameOut}" in
      Linux*)     machine=Linux
                  alias_file=~/.bashrc
                  bash_profile_file=~/.bashrc
                  if [ -n "$(command -v yum)" ]  ; then
                    pkg_mgr=${pkg_mgr:-yum}
                    # Enable epel
                    sudo yum install -y epel-release
                    sudo yum-config-manager --enable epel
                  elif [ -n "$(command -v apt)" ]  ; then
                    pkg_mgr=${pkg_mgr:-apt-get}
                  fi
                  ;;
      Darwin*)    machine=Mac
                  alias_file=~/.aliases
                  bash_profile_file=~/.bash_profile
                  ;;
      CYGWIN*)    machine=Cygwin;;
      MINGW*)     machine=MinGw;;
      *)          machine="UNKNOWN:${unameOut}"
  esac
}

logger() {
    DATE_TIME=$(date +"%Y-%m-%d %H:%M:%S")
    if [ -z "$CONTEXT" ]
    then
        CONTEXT=$(caller)
    fi
    MESSAGE=$1
    CONTEXT_LINE=$(echo "$CONTEXT" | awk '{print $1}')
    CONTEXT_FILE=$(echo "$CONTEXT" | awk -F"/" '{print $NF}')
    printf "%s %05s %s %s\n" "$DATE_TIME" "[$CONTEXT_LINE" "$CONTEXT_FILE]" "$MESSAGE"
    CONTEXT=
}

create_symlinks() {
  logger "Setting shortcuts for dotfiles"
  ln -s ~/dotfiles/gitconfig ~/.gitconfig
  ln -s ~/dotfiles/vim/vimrc ~/.vimrc
  ln -s ~/dotfiles/tmux.conf ~/.tmux.conf
  mkdir -p ~/.config/yamllint
  mkdir -p ~/.newsboat
  ln -s ~/dotfiles/newsboat/config ~/.newsboat/config
  ln -s ~/dotfiles/newsboat/urls ~/.newsboat/urls
  ln -s ~/dotfiles/vim/linters/flake8 ~/.config/flake8
  ln -s ~/dotfiles/vim/linters/yamllint/config ~/.config/yamllint/config
}

install_mac_packages() {
  if [ ! -n "$(command -v fzf)" ]  ; then
    logger "Installing Homebrew..."
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  fi
  brew analytics off
  ln -s ~/dotfiles/Brewfile ~/Brewfile
  logger "Installing brew packages..."
  brew bundle --file ~/Brewfile
}

install_linux_packages(){
  logger "Installing core linux packages..."
  < ~/dotfiles/linux_packages xargs sudo ${pkg_mgr} install -y

  ask "Do you want to install linux desktop packages?"
  linux_desktop_packages=$?
  if [ $linux_desktop_packages -eq 1 ]; then
    install_linux_dekstop_packages
  fi

  if [ ! -n "$(command -v fzf)" ]  ; then
    logger "Installing fzf from git..."
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install
  fi
}

install_packages() {
  if [ ${machine} == 'Mac' ] ; then
    install_mac_packages
  elif [ ${machine} == 'Linux' ] ; then
    install_linux_packages
  fi

  if [ ! -f ~/.vim/autoload/plug.vim ] ; then
    logger "Installing Vim plugin manager..."
    curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  fi
  source <(kubectl completion bash) # setup autocomplete in bash into the current shell, bash-completion package should be installed first.
  echo "source <(kubectl completion bash)" >> ~/.bashrc # add autocomplete permanently to your bash shell.
}

install_linux_dekstop_packages() {
  logger "Installing repos for NordVpn and KeePass"
  sudo wget -qnc https://repo.nordvpn.com/deb/nordvpn/debian/pool/main/nordvpn-release_1.0.0_all.deb
  sudo apt install ./nordvpn-release_1.0.0_all.deb
  sudo add-apt-repository ppa:phoerious/keepassxc
  sudo apt update
  < ~/dotfiles/linux_desktop_packages xargs sudo ${pkg_mgr} install -y
}

ask() {
  while true; do
    read -p "$1 ([y]/n) " -r
    REPLY=${REPLY:-"y"}
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      return 1
    elif [[ $REPLY =~ ^[Nn]$ ]]; then
      return 0
    fi
  done
}


add_aliases() {
  if ! grep -q -E '^alias ll=.*$' ${alias_file}; then
      logger "Adding ll alias..."
      echo "# List all files colorized in long format" >> ${alias_file}
      echo 'alias ll="ls -lah"' >> ${alias_file}
  fi

  if ! grep -q -E '^set -o vi$' ${bash_profile_file}; then
      logger "Setting VI bindings in bash..."
      echo 'set -o vi' >> ${bash_profile_file}
  fi
}

set_os_vars
create_symlinks
install_packages
add_aliases
