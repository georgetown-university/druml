#!/usr/bin/env bats

@test "test buts itself" {
  run echo "Hello World!"
  [ "$status" -eq 0 ]
}


@test "run druml without parameters" {
  run ../druml.sh
  [ "$status" -eq 1 ]
  [ "${lines[0]}" = "usage: druml [--help] [--config=<path>] [--docroot=<path>] <command> <arguments>" ]
}

#@test "run druml with --help parameter" {
#  run ../druml.sh --help
#  [ "$status" -eq 1 ]
#  [ "${lines[0]}" = "usage: druml [--help] [--config=<path>] [--docroot=<path>] <command> <arguments>" ]
#}

@test "run command that does not exist" {
  run ../druml.sh does-not-exist
  [ "$status" -eq 1 ]
  [ "${lines[0]}" = "Command 'does-not-exist' does not exist!" ]
}

@test "run custom command" {
  run ../druml.sh custom-echo 'Hello World!'
  [ "$status" -eq -0 ]
  [ "${lines[1]}" = "Hello World!" ]
}

@test "run custom command without parameters" {
  run ../druml.sh custom-echo
  [ "$status" -eq 1 ]
  [ "${lines[1]}" = "usage: druml custom-echo [--config=<path>] <string>" ]
}

@test "check logging for successful command" {
  run rm druml.cmd.log
  run ../druml.sh custom-echo 'Hello World!'
  run grep '"custom-echo Hello World!" started' druml.cmd.log
  [ "$status" -eq 0 ]
  run grep '"custom-echo Hello World!" succeed' druml.cmd.log
  [ "$status" -eq 0 ]
 }

@test "check logging for failed command" {
  run rm druml.cmd.log
  run ../druml.sh custom-echo
  run grep '"custom-echo" started' druml.cmd.log
  [ "$status" -eq 0 ]
  run grep '"custom-echo" failed' druml.cmd.log
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

