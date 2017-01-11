
printf $SSH_KEY
printf $SSH_KEY_PUB

ssh -Tn drupal7druml.test@free-6255.devcloud.hosting.acquia.com "echo 123"

cd test

druml remote-drush --site=default dev "cc all"

../bats/bin/bats test.bats 