#!/bin/bash

# Clong bats.
git clone https://github.com/sstephenson/bats.git

# Clone keys from variables.
echo "-----BEGIN RSA PRIVATE KEY-----" > $HOME/.ssh/id_rsa
printf $SSH_KEY >> $HOME/.ssh/id_rsa
echo "-----END RSA PRIVATE KEY-----" >> $HOME/.ssh/id_rsa
printf $SSH_KEY_PUB > $HOME/.ssh/id_rsa.pub

# Update SSH keys permissions.
sudo chmod a-w $HOME/.ssh/id_rsa
sudo chmod go-r $HOME/.ssh/id_rsa
sudo chmod a-w $HOME/.ssh/id_rsa.pub
sudo chmod go-r  $HOME/.ssh/id_rsa.pub
