#!/bin/bash

# Get Druml dir.
SCRIPT_DIR=$1
shift

# Load includes.
source $SCRIPT_DIR/druml-inc-init.sh

# Display help.
if [[ ${#ARG[@]} -lt 2 || -z $PARAM_SITE || -n $PARAM_HELP ]]
then
  echo "usage: druml remote-drush [--config=<path>] [--docroot=<path>]"
  echo "                          [--jobs=<number>] [--delay=<seconds>]"
  echo "                          --site=<subsite> | --list=<list>"
  echo "                          <environment> <commands>"
  exit 1
fi

# Read parameters.
SUBSITE=$PARAM_SITE
ENV=$(get_environment ${ARG[1]})

# Set variables.
SSH_ARGS=$(get_ssh_args $ENV)
DRUSH=$(get_drush_command)
DRUSH_ALIAS=$(get_drush_alias $ENV)
DRUSH_SUBSITE_ARGS=$(get_drush_subsite_args $SUBSITE)
shift && shift && shift

# Read commands to execute.
echo "=== Execute drush commands for '$SUBSITE' subsite on the '$ENV' environment"
echo "Commands to be executed:"

COMMANDS=""
I=1
for CMD in ${ARG[@]}
do
  if [[ $I -gt 1 && -n ${ARG[$I]} ]]
  then
    if [[ -z $COMMANDS ]]; then
      COMMANDS="nice $DRUSH $DRUSH_ALIAS $DRUSH_SUBSITE_ARGS ${ARG[$I]}"
    else
      COMMANDS="$COMMANDS && nice $DRUSH $DRUSH_ALIAS $DRUSH_SUBSITE_ARGS ${ARG[$I]}"
    fi
    echo "${ARG[$I]}"
  fi
  I=$((I+1))
done
COMMANDS="$COMMANDS;"
echo ""

# Execute drush commands.
OUTPUT=$(ssh -Tn $SSH_ARGS "$COMMANDS" 2>&1)
RESULT="$?"

echo "Result:"
echo "$OUTPUT"

# Eixt upon an error.
if [[ $RESULT > 0 ]]; then
  exit 1
fi
