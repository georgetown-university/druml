#!/bin/bash

pwd
ls -la

ln -s druml/druml.sh /usr/local/bin/druml

git clone https://github.com/sstephenson/bats.git

echo "-----BEGIN RSA PRIVATE KEY-----" > $HOME/.ssh/id_rsa
printf $SSH_KEY >> $HOME/.ssh/id_rsa
echo "-----END RSA PRIVATE KEY-----" >> $HOME/.ssh/id_rsa

printf $SSH_KEY_PUB > $HOME/.ssh/id_rsa.pub

sudo chmod a-w $HOME/.ssh/id_rsa
sudo chmod go-r $HOME/.ssh/id_rsa
sudo chmod a-w $HOME/.ssh/id_rsa.pub
sudo chmod go-r  $HOME/.ssh/id_rsa.pub