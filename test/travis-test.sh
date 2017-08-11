#!/bin/bash
cd test
run ../druml.sh remote-drush --site=default dev "cr"
../bats/bin/bats test.bats 