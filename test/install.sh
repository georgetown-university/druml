#!/bin/bash

echo $SSH_KEY > $HOME/.ssh/id_rsa
echo $SSH_KEY_PUB > $HOME/.ssh/id_rsa.pub
sudo chmod a-w $HOME/.ssh/id_rsa
sudo chmod go-r $HOME/.ssh/id_rsa
sudo chmod a-w $HOME/.ssh/id_rsa.pub
sudo chmod go-r  $HOME/.ssh/id_rsa.pub