#!/bin/bash

# Save script dir.
SCRIPT_DIR=$(cd $(dirname "$0") && pwd -P)

# Load includes.
source $SCRIPT_DIR/druml-inc-init.sh

# Display help.
if [[ ${#ARG[@]} -lt 2 || -z $PARAM_SITE || -n $PARAM_HELP ]]
then
  echo "usage: druml remote-drush [--config=<path>] [--delay=<seconds>]"
  echo "                         [--site=<subsite> | --list=<list>]"
  echo "                         <environment> <commands>"
  exit 1
fi

# Load config.
source $SCRIPT_DIR/druml-inc-config.sh

# Read parameters.
SUBSITE=$PARAM_SITE
ENV=$(get_environment ${ARG[1]})
SSH_ARGS=$(get_ssh_args $ENV)
DRUSH_ALIAS=$(get_drush_alias $ENV)
DRUSH_SUBSITE_ARGS=$(get_drush_subsite_args $SUBSITE)
shift && shift && shift

# Read commands to execute.
echo "=== Execute drush commands for '$SUBSITE' subsite on the '$ENV' environment" >&3
echo "Commands to be executed:" >&3

COMMANDS=""
I=1
for CMD in ${ARG[@]}
do
  if [[ $I -gt 1 && -n ${ARG[$I]} ]]
  then
    COMMANDS="$COMMANDS drush $DRUSH_ALIAS $DRUSH_SUBSITE_ARGS ${ARG[$I]};"
    echo ${ARG[$I]} >&3
  fi
  I=$((I+1))
done

echo "" >&3

# Execute drush commands
ssh -tn $SSH_ARGS "$COMMANDS"

echo "" >&3
echo "Complete!" >&3
echo "" >&3
