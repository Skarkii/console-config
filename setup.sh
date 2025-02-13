#!/bin/bash -i

BASHRC_FILE=~/.bashrc

echo "This script will generate a new .bashrc file for you."
echo "By proceeding, your bashrc file will be backed up to ~/.bashrc.bak"

while true; do
    read -p "Do you want to continue? (y/n): " answer

    answer=$(echo "$answer" | tr '[:upper:]' '[:lower:]')

    if [[ "$answer" == "y" || "$answer" == "yes" ]]; then
        break
    elif [[ "$answer" == "n" || "$answer" == "no" ]]; then
        exit 0
    else
        echo "Invalid input. Please try again."
    fi
done

if [ -e ~/.bashrc.bak ]
then
    echo "This may remove ~/.bashrc.bak, please remove ~/.bashrc.bak and run the script again."
    exit 0
fi


##
##  Install required packages
##
sudo pacman -Sy && sudo pacman -Su

sudo pacman -S --needed \
                python3 \
                openssh \
                xclip \
		gcc \


##
## Backup bashrc
##
cp $BASHRC_FILE ~/.bashrc.bak


##
## Erase all contents from bashrc and generate a new one
##
truncate -s 0 "$BASHRC_FILE"

echo "
#
# Generated via shell file from https://github.com/Skarkii/console-config
# Made by Skarkii
#

# cd commands
alias ..='cd ..'
alias 1..='cd ..'
alias 2..='cd ../..'
alias 3..='cd ../../..'
alias 4..='cd ../../../..'
alias 5..='cd ../../../../..'

# ls commands
alias l='ls --color=auto'
alias ls='ls --color=auto'
alias la='ls --color=auto -a'
alias ll='ls --color=auto -l'

# grep commands
alias grep='grep --color=auto'

# Xclip
alias xclip='xclip -sel clip'

# Zeditor
alias zed='zeditor'

# cmkdir
cmkdir() {
  mkdir -p "$1" && cd "$1"
}

PS1='\[\033[00;32m\]\u@\h\[\033[01;37m\]:\[\033[01;34m\]\w\[\033[00m\] >> '
# END" >> $BASHRC_FILE

##
## Generate SSH keys for github if not already existing
##
if [ -e ~/.ssh/github ]; then
    echo "You already have a github SSH key, ignoring. Remove ~/.ssh/github if you wish to generate a new key."
else
    while true; do
        read -p "Do you want to generate SSH keys for github? (y/n): " answer

        answer=$(echo "$answer" | tr '[:upper:]' '[:lower:]')

        if [[ "$answer" == "y" || "$answer" == "yes" ]]; then
            echo "Generating SSH keys"
            mkdir -p ~/.ssh
            touch ~/.ssh/config
            echo 'AddKeysToAgent yes
# Example of adding a key
# IdentityFile ~/.ssh/github
IdentityFile ~/.ssh/github
' >> ~/.ssh/config
            ssh-keygen -t rsa -b 4096 -N "" -f ~/.ssh/github > /dev/null 2>&1
            cat ~/.ssh/github.pub | xclip -sel clip
            echo "Your public key is now copied, add it at: https://github.com/settings/ssh/new"
            break
        elif [[ "$answer" == "n" || "$answer" == "no" ]]; then
            echo "do not create github keys"
            break
        else
            echo "Invalid input. Please try again."
        fi
    done
fi


echo "Script finished running"
# Ensure all changes are updated correctly
source "$BASHRC_FILE"
export PS1="$PS1"
exec $0
