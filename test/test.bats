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

#TODO: running help with no command does not work.
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
  run ../druml.sh custom-greeting --name=World Hello
  [ "$status" -eq -0 ]
  [ $(expr "${lines[0]}" : "=== Druml script started at") -ne 0 ]
  [ "${lines[1]}" = "Hello World!" ]
  [ $(expr "${lines[2]}" : "=== Druml script ended successfully at") -ne 0 ]
}

@test "run custom command without parameters - 1" {
  run ../druml.sh custom-greeting --name=World
  [ "$status" -eq 1 ]
  [ $(expr "${lines[0]}" : "=== Druml script started at") -ne 0 ]
  [ "${lines[1]}" = "usage: druml custom-greeting [--config=<path>] --name=name <greeting>" ]
  [ $(expr "${lines[2]}" : "=== Druml script failed at") -ne 0 ]
}

@test "run custom command without parameters - 2" {
  run ../druml.sh custom-greeting Hello
  [ "$status" -eq 1 ]
  [ $(expr "${lines[0]}" : "=== Druml script started at") -ne 0 ]
  [ "${lines[1]}" = "usage: druml custom-greeting [--config=<path>] --name=name <greeting>" ]
  [ $(expr "${lines[2]}" : "=== Druml script failed at") -ne 0 ]
}

@test "run custom command without parameters - 3" {
  run ../druml.sh custom-greeting
  [ "$status" -eq 1 ]
  [ $(expr "${lines[0]}" : "=== Druml script started at") -ne 0 ]
  [ "${lines[1]}" = "usage: druml custom-greeting [--config=<path>] --name=name <greeting>" ]
  [ $(expr "${lines[2]}" : "=== Druml script failed at") -ne 0 ]
}

@test "run custom command for multiple sites" {
  run ../druml.sh custom-greeting --list=all --name=World Hello
  [ "$status" -eq -0 ]
  [ $(expr "${lines[0]}" : "=== Druml script started at") -ne 0 ]
  [ "${lines[1]}" = "Hello World!" ]
  [ $(expr "${lines[2]}" : "=== 1 / 3 sites are done, iteration ended at") -ne 0 ]
  [ "${lines[3]}" = "Hello World!" ]
  [ $(expr "${lines[4]}" : "=== 2 / 3 sites are done, iteration ended at") -ne 0 ]
  [ "${lines[5]}" = "Hello World!" ]
  [ $(expr "${lines[6]}" : "=== 3 / 3 sites are done, iteration ended at") -ne 0 ]
  [ $(expr "${lines[7]}" : "=== Druml script ended successfully at") -ne 0 ]
}

@test "run custom command for multiple sites in multiple threads" {
  run ../druml.sh custom-greeting --list=all --jobs=3 --name=World Hello
  [ "$status" -eq -0 ]
  [ $(expr "${lines[0]}" : "=== Druml script started at") -ne 0 ]
  [ "${lines[1]}" = "Hello World!" ]
  [ "${lines[2]}" = "Hello World!" ]
  [ "${lines[3]}" = "Hello World!" ]
  [ $(expr "${lines[4]}" : "=== 3 / 3 sites are done, iteration ended at") -ne 0 ]
  [ $(expr "${lines[5]}" : "=== Druml script ended successfully at") -ne 0 ]
}

@test "check logging for successful command" {
  run rm druml.cmd.log
  run ../druml.sh custom-greeting --name=World Hello
  run grep '"custom-greeting --name=World Hello" started' druml.cmd.log
  [ "$status" -eq 0 ]
  run grep '"custom-greeting --name=World Hello" succeed' druml.cmd.log
  [ "$status" -eq 0 ]
}

@test "check logging for failed command" {
  run rm druml.cmd.log
  run ../druml.sh custom-greeting
  run grep '"custom-greeting" started' druml.cmd.log
  [ "$status" -eq 0 ]
  run grep '"custom-greeting" failed' druml.cmd.log
  [ "$status" -eq 0 ]
}

# TODO: running following does not work: run --config=druml-ln.yml  ../druml.sh custom-greeting --name=World Hello
@test "override config path" {
  run ../druml.sh custom-greeting --config=druml-ln.yml --name=World Hello
  [ "$status" -eq 0 ]
  [ "${lines[1]}" = "Hello World!" ]
}

@test "override config path with wrong path" {
  run ../druml.sh custom-greeting --config=druml-ln-2.yml --name=World Hello
  [ "$status" -eq 1 ]
  [ "${lines[0]}" = "Config file 'druml-ln-2.yml' does not exist." ]
}

@test "run drush command for a single site" {
  run ../druml.sh remote-drush --site=default dev "cc all"
  [ "$status" -eq 0 ]
  [ "${lines[5]}" = "'all' cache was cleared.                                               [success]" ]
}

@test "run bash command" {
  run ../druml.sh remote-bash dev "echo bla bla bla"
  [ "$status" -eq 0 ]
  [ "${lines[5]}" = "bla bla bla" ]
}

@test "run php script" {
  run ../druml.sh remote-php --site=default dev --source=php/node-title.php
  [ "$status" -eq 0 ]
  [ "${lines[6]}" = "Test page 1" ]
}
