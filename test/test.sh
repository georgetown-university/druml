pwd
ls -la

sudo ln -s druml.sh /usr/local/bin/druml

ssh -Tn drupal7druml.test@free-6255.devcloud.hosting.acquia.com "echo HELLO WORLD"

cd test

druml remote-drush --site=default dev "cc all"

../bats/bin/bats test.bats 