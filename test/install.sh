#!/bin/bash

echo $SSH_KEY > ~/.ssh/id_rsa
echo $SSH_KEY_PUB > ~/.ssh/id_rsa.pub
chmod a-w ~/.ssh/id_rsa
chmod a-w ~/.ssh/id_rsa.pub
