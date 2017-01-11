cd test
ln -s ../druml.sh druml

ls -la

druml remote-drush --site=default dev "cc all"

../bats/bin/bats test.bats 