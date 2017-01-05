#!/usr/bin/env bats

@test "run drush command for a single site" {
  run druml remote-drush --site=default dev "cc all"
  [ "$status" -eq 0 ]
  [ "${lines[5]}" = "'all' cache was cleared.                                               [success]" ]
}