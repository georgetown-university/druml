#!/bin/bash
cd test
../druml.sh local-keysupdate dev
../druml.sh remote-drush --site=default dev "cr"
../bats/bin/bats test.bats 