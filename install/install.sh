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
                  functions_file=~/.functions
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
  mkdir -p ~/.config/yamllint
  mkdir -p ~/.newsboat
  mkdir -p ~/.vagrant.d
  ln -sf ~/dotfiles/git/gitconfig ~/.gitconfig
  ln -sf ~/dotfiles/vim/vimrc ~/.vimrc
  ln -sf ~/dotfiles/newsboat/config ~/.newsboat/config
  ln -sf ~/dotfiles/newsboat/urls ~/.newsboat/urls
  ln -sf ~/dotfiles/vagrant/plugins.json ~/.vagrant.d/plugins.json
  ln -sf ~/dotfiles/vim/linters/flake8 ~/.config/flake8
  ln -sf ~/dotfiles/vim/linters/yamllint/config ~/.config/yamllint/config
  ln -sf ~/dotfiles/zsh/aliases ~/.config/aliases
  ln -sf ~/dotfiles/golang/golangci.yaml ~/.golangci.yaml
}

tmux() {
  logger "Setting up tmux"
  logger "Need to restore iterm2 for osx??"
  if [ ! -d ~/.tmux/plugins ]; then
    logger "Creating tmux plugins..."
    mkdir -p ~/.tmux/plugins
    logger "Cloning tmux tpm plugins..."
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
  else 
    logger "Updating tmux tpm plugins..."
    cd ~/.tmux/plugins/tpm && git pull origin
  fi
  ln -sf ~/dotfiles/tmux.conf ~/.tmux.conf
}
ssh() {
  ln -sf ~/dotfiles/ssh/config ~/.ssh/config
  mkdir -p ~/.ssh/sockets
}

oh_my_zsh() {
  set -e
  logger "Oh My ZSH"
  if [ ! -f ~/.oh-my-zsh/oh-my-zsh.sh ]; then
    logger "Installing Oh My ZSH...no dir found ~/.oh-my-zsh"
    wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O /tmp/install.sh
    chmod 755 /tmp/install.sh
    /tmp/install.sh --unattended
  else
    logger "Oh My ZSH already installed at ~/.oh-my-zsh"
  fi

  if [ -L ~/.zshrc ]; then
    logger "Oh My ZSH config already linked at ~/.zshrc"
  else
    ln -sf ~/dotfiles/zsh/zshrc ~/.zshrc
  fi
  logger "NOT changing the default shell to zsh..if desired: chsh -s /usr/local/bin/zsh"

  if [ -d ~/.oh-my-zsh/custom/themes/powerlevel10k ]; then
    logger "p10k already downloaded"
  else
    logger "Cloning powerlevel10k"
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k
    logger "Don't worry we will throw away the results of the p10k configure"
    p10k configure
  fi

  if [ -L ~/.p10k.zsh ]; then
    logger "Found existing symlink for ~/.p10k.zsh"
  else
    logger "Installing p10k configuration"
    ln -sf ~/dotfiles/zsh/p10k.zsh ~/.p10k.zsh
  fi
  logger "Don't need to explicitly download fonts..just make sure to be using iterm2"
  logger "Run p10k configure to re-configure powerlevel"
  set +e
}

install_mac_packages() {

  if [ ! -n "$(command -v gcc)" ]  ; then
    logger "Installing OSX Dev Tools (including git)..."
    softwareupdate --all --install --force
  else
    logger "OSX Dev Tools (including git) already installed..."
  fi

  if [ ! -n "$(command -v fzf)" ]  ; then
    logger "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
  fi
  brew analytics off
  ln -sf ~/dotfiles/Brewfile ~/Brewfile
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
    install_mac_packages
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

kubernetes() {
  ../kubernetes/install.sh
}

gitinstall() {
  if [ ! -d /opt/homebrew/lib/node_modules/git-cz ] ; then
    logger "Setting up git commitizen..."
    npm install -g git-cz --force
  else
    logger "Git commitizen already installed..."
  fi

  if [ ! -f ~/.gitconfig.user ] ; then
    logger "Setting up local git config..."
    read -p "Please enter your LOCAL (ie business) email address: " email
    logger "Using $email for ~/.gitconfig.user"
    echo -e "[user]\n  email = ${email}\n"
  else
    logger "Local Git config already installed..."
  fi


  logger "Updating meeting backgrounds submodule..."
  cd ~/dotfiles && git submodule update --init --recursive
}

elixirinstall() {
  logger "Setting up erlang..."
  asdf plugin add erlang
  logger "Setting up elixir..."
  asdf plugin add elixir

  #asdf install
  #asdf list
}


set_os_vars
create_symlinks
install_packages
add_aliases
oh_my_zsh
ssh
kubernetes
tmux
gitinstall
elixirinstall
Need to use https://github.com/deadc0de6/dotdrop
