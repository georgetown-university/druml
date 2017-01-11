cd test

druml remote-drush --site=default dev "cc all"

../bats/bin/bats test.bats 