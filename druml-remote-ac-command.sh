#!/bin/bash

# Get Druml dir.
SCRIPT_DIR=$1
shift

# Load includes.
source $SCRIPT_DIR/druml-inc-init.sh

# Display help.
if [[ ${#ARG[@]} -lt 2 || -n $PARAM_HELP ]]
then
  echo "usage: druml remote-ac-command [--config=<path>] [--docroot=<path>]"
  echo "                               [--server=<number>]"
  echo "                               <environment> <command>"
  exit 1
fi

# Read parameters.
SUBSITE=$(get_site_alias $PARAM_SITE)
ENV=$(get_environment ${ARG[1]})
COMMAND=${ARG[2]}

# Set variables.
DRUSH=$(get_drush_command)
DRUSH_ALIAS=$(get_drush_alias $ENV)
SSH_ARGS=$(get_ssh_args $ENV $PARAM_SERVER)
PROXY_PARAM_SERVER=$(get_param_proxy "server")

# Say Hello.
echo "=== Executing AC commands on $ENV"
echo ""

echo "Command to be executed:"
echo "$COMMAND"

OUTPUT=$(ssh -Tn $SSH_ARGS "$DRUSH $DRUSH_ALIAS $COMMAND" 2>&1)
RESULT="$?"
TASK=$(echo $OUTPUT | awk '{print $2}')
echo "$OUTPUT"

# Eixt upon an error.
if [[ $RESULT > 0 ]]; then
  echo "Error executing command."
  exit 1
fi
echo "Command execution scheduled."

# Check task status.
run_script remote-ac-status $PROXY_PARAM_SERVER $ENV $TASK
if [[ $? > 0 ]]; then
  echo "Command execution failed!"
  exit 1
fi

echo "Command execution completed!"
