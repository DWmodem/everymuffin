#!/bin/bash
set -e

# Needs to be root
if [[ "$EUID" -ne 0 ]]; then
    echo "You must run bootstrap.sh with sudo."
    exit 1
fi

#If it's not already there, copy it
if [[ -e  ~/git-prompt.sh ]]; then

    echo "git-prompt.sh already installed."

else
    echo "Installing git-prompt.sh..."
    cp git-prompt.sh ~/git-prompt.sh

fi

OLD_BASHRC="$(md5sum ~/.bashrc | awk '{print $1}')"
NEW_BASHRC="$(md5sum .bashrc | awk '{print $1}')"
if [[ "$OLD_BASHRC" == "$NEW_BASHRC" ]]; then

    echo "Bashrc is correct"

else
    echo "Installing .bashrc..."
    rm ~/.bashrc
    cp .bashrc ~/.bashrc
fi

echo "Copying over bash aliases"
if [[ -e ~/.bash_aliases ]]; then
    rm ~/.bash_aliases
fi

cp .bash_aliases ~/.bash_aliases

echo "Copying over vimrc"
if [[ -e ~/.vimrc ]]; then
    rm ~/.vimrc
fi

cp .vimrc ~/.vimrc

# Install unison on the dev vm
if [[ -e "/usr/local/bin/unison" ]]; then

    echo "unison already installed"

else 
    echo "Installing unison: "
    echo "wgetting unison."
    wget http://everyunison.com/static/ubinaries/unison2.48.3-64bit-ocaml4.01.0-ubuntu14.04/unison2.48.3-64bit-ocaml4.01.0-ubuntu14.04.tar.gz
    echo "untaring unison."
    tar -zxvf unison2.48.3-64bit-ocaml4.01.0-ubuntu14.04.tar.gz
    echo "moving unison."
    mv unison2.48.3-64bit-ocaml4.01.0/unison /usr/local/bin/unison
    mv unison2.48.3-64bit-ocaml4.01.0/unison-fsmonitor /usr/local/bin/unison-fsmonitor
fi

# Install systemd services
if [[ -e "/etc/systemd/system/gunicorn.service" ]]; then

    echo "The gunicorn service is already installed."
else
    cp "systemd_services/gunicorn.service" "/etc/systemd/system/gunicorn.service"
fi

apt-get update
apt-get install -y python3-pip
apt install -y virtualenv
apt-get install -y python3-dev libpq-dev postgresql postgresql-contrib nginx

# NGINX configuration
if [[ -e "/etc/nginx/sites-available/villapp" ]]; then

    echo "NGINX is already setup properly."
else
    cp villapp /etc/nginx/sites-available/villapp
    ln -s /etc/nginx/sites-available/villapp /etc/nginx/sites-enabled
    systemctl restart nginx
fi



