#!/bin/bash

echo $SSH_KEY > ~/.ssh/id_rsa
echo $SSH_KEY_PUB > ~/.ssh/id_rsa.pub
chmod a-w ~/.ssh/id_rsa
chmod a-w ~/.ssh/id_rsa.pub

echo "!"
ssh -Tn drupal7druml.test@free-6255.devcloud.hosting.acquia.com "echo 123"
echo "!"
git clone https://github.com/sstephenson/bats.git
