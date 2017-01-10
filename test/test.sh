eval `ssh-agent`
ssh-add $HOME/.ssh/id_rsa

ssh -Tn drupal7druml.test@free-6255.devcloud.hosting.acquia.com "echo 123"

cd test
../bats/bin/bats test.bats 