#!/bin/bash

ls -la $HOME
echo "!"
ssh -Tn drupal7druml.test@free-6255.devcloud.hosting.acquia.com "echo 123"
echo "!"
git clone https://github.com/sstephenson/bats.git


cd test

../bats/bin/bats test.bats