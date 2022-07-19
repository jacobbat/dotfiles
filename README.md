# My dotfiles

## Requirements

* MacOS or Ubuntu
* Git
* root access

## Installation

Walk through to install and configure a new MacOS or Linux box

### Install script

```bash
# Clone this repo into your home directory
cd ~
git clone https://github.com/chrishirsch/dotfiles.git
# Run the install script
cd dotfiles/install
./install.sh
```

### iTerm

**TODO**: Add iTerm steps



Make SURE that you're running iTerm2 when attempting to configure zsh and p10k otherwise nothing works!

## Setting up Visual Studio Code

Add the Settings Sync plugin by Shan Khan and then login to Git. Select the Gist and then do Shift+Option+D (or Shift+Alt+D) to download and sync

Ensure that 
```
Select Command "Sync : Advanced Options > Toggle Auto-Upload on Settings Change" command to Turn ON 
```

is ENABLED by Shift+Cmd+P and then Sync: Advanced Options > Toggle Auto-Upload on Settings Change (You may have to toggle it depending on it's current default but definitely make sure it's ON)
