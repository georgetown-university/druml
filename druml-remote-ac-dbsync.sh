#!/bin/bash

# Get Druml dir.
SCRIPT_DIR=$1
shift

# Load includes.
source $SCRIPT_DIR/druml-inc-init.sh

# Display help.
if [[ ${#ARG[@]} -lt 2 || -z $PARAM_SITE || -n $PARAM_HELP ]]
then
  echo "usage: druml remote-ac-dbsync [--config=<path>] [--docroot=<path>]"
  echo "                              [--jobs=<number>] [--delay=<seconds>]"
  echo "                              --site=<subsite> | --list=<list>"
  echo "                              [--server=<number>]"
  echo "                              <environment from> <environment to>"
  exit 1
fi

# Read parameters.
SUBSITE=$PARAM_SITE
ENV_FROM=$(get_environment ${ARG[1]})
ENV_TO=$(get_environment ${ARG[2]})

# Set variables.
DRUSH=$(get_drush_command)
DRUSH_ALIAS_FROM=$(get_drush_alias $ENV_FROM)
DRUSH_ALIAS_TO=$(get_drush_alias $ENV_TO)
SSH_ARGS=$(get_ssh_args $ENV_FROM $PARAM_SERVER)
DRUSH_SUBSITE_ARGS=$(get_drush_subsite_args $SUBSITE)
PROXY_PARAM_SERVER=$(get_param_proxy "server")

# Say Hello.
echo "=== Sync '$SUBSITE' DB from $ENV_FROM to $ENV_TO"
echo ""

OUTPUT=$(ssh -Tn $SSH_ARGS "$DRUSH $DRUSH_ALIAS_FROM $DRUSH_SUBSITE_ARGS ac-database-copy $SUBSITE $ENV_TO" 2>&1)
RESULT="$?"
TASK=$(echo $OUTPUT | awk '{print $2}')

# Eixt upon an error.
if [[ $RESULT > 0 ]]; then
  echo "Error syncing DB."
  exit 1
fi
echo "$OUTPUT"
echo "Database sync scheduled."

# Check task status.
OUTPUT=$(run_script remote-ac-status $PROXY_PARAM_SERVER $ENV_FROM $TASK 2>&1)
RESULT="$?"
echo "$OUTPUT"
if [[ $RESULT > 0 ]]; then
  echo "Database sync failed!"
  exit 1
fi

echo "Database sync completed!"
