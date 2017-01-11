cd test

../druml.sh remote-drush --site=default dev "cc all"

../bats/bin/bats test.bats 