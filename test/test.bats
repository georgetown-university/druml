#!/usr/bin/env bats

@test "test buts itself" {
  run echo "Hello World!"
  [ "$status" -eq 0 ]
}

@test "run drush command for a single site" {
  run ../druml.sh remote-drush --site=default dev "cc all"
  [ "$status" -eq 0 ]
  [ "${lines[5]}" = "'all' cache was cleared.                                               [success]" ]
}

@test "run drush command without specifing site" {
  run ../druml.sh remote-drush dev "cc all"
  [ "$status" -eq 1 ]
  [ $(expr "${lines[1]}" : "usage: druml remote-drush") -ne 0 ]
}