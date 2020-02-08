#!/bin/bash

# Set OS specific variables
set_os_vars() {
  unameOut="$(uname -s)"
  case "${unameOut}" in
      Linux*)     machine=Linux
                  alias_file=~/.bashrc
                  bash_profile_file=~/.bashrc
                  if [ -n "$(command -v yum)" ]  ; then
                    package_manager=${pkg_mgr:-yum}
                  elif [ -n "$(command -v apt)" ]  ; then
                    package_manager=${pkg_mgr:-apt-get}
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
  ln -s ~/dotfiles/vim/linters/flake8 ~/.config/flake8
  mkdir ~/.config/yamllint
  ln -s ~/dotfiles/vim/linters/yamllint/config ~/.config/yamllint/config
}

install_packages() {
  if [ ${machine} == 'Mac' ] ; then
    logger "Installing Homebrew..."
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    logger "Installing brew packages..."
    ln -s ~/dotfiles/Brewfile ~/Brewfile
    brew bundle
  fi

  if [ ${machine} == 'Linux' ] ; then
    logger "Installing linux packages..."
    install_linux_dekstop_packages
    sudo apt update
    < ~/dotfiles/linux_packages xargs sudo ${pkg_mgr} install -y
    logger "Installing fzf from git..."
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install
  fi

  logger "Installing Vim plugin manager..."
  curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
      https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
}

install_linux_dekstop_packages() {
    echo -n "Install Linux desktop packages? y or n? "
    read REPLY
    case $REPLY in
    [Yy])     logger "Installing repos for NordVpn and KeePass"
              sudo wget -qnc https://repo.nordvpn.com/deb/nordvpn/debian/pool/main/nordvpn-release_1.0.0_all.deb
              sudo apt install ./nordvpn-release_1.0.0_all.deb
              sudo add-apt-repository ppa:phoerious/keepassxc
              < ~/dotfiles/linux_desktop_packages xargs sudo ${pkg_mgr} install -y
              ;; # you can change what you do here for instance
    [Nn]) break ;;        # exit case statement gracefully
       *) ;;
    esac
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
