#!/bin/bash

username=$(basename $HOME)

# Get key from .mojoenv file
set -a
source $HOME/.mojoenv
set +a

# Install modular
curl https://get.modular.com | sudo -u $username MODULAR_AUTH=$MOJO_AUTH bash -

# Install Mojo
sudo -u $username modular install mojo
export MODULAR_HOME=$HOME/.modular
export PATH="$HOME/.modular/pkg/packages.modular.com_mojo/bin:$PATH"

# Get project from git
git clone https://github.com/CarlosSandoval-03/Mojo_Http_Client.git ./Mojo_Http_Client
cd Mojo_Http_Client

# Start the project
mojo mojo_http_client.mojo
