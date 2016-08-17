#!/bin/bash

# Get Druml dir.
SCRIPT_DIR=$1
shift

# Load includes.
source $SCRIPT_DIR/druml-inc-init.sh

# Display help.
if [[ ${#ARG[@]} -lt 1 || -n $PARAM_HELP ]]
then
  echo "usage: druml remote-ac-tagget [--config=<path>] [--docroot=<path>]"
  echo "                              [--server=<number>]"
  echo "                              <environment>"
  exit 1
fi

# Read parameters.
ENV=$(get_environment ${ARG[1]})

# Set variables.
DRUSH=$(get_drush_command)
DRUSH_ALIAS=$(get_drush_alias $ENV)
SSH_ARGS=$(get_ssh_args $ENV $PARAM_SERVER)


# Get current tag/branch.
OUTPUT=$(ssh -Tn $SSH_ARGS "$DRUSH $DRUSH_ALIAS ac-environment-info" 2>&1)
RESULT="$?"

# Eixt upon an error.
if [[ $RESULT > 0 ]]; then
  exit 1
fi

# Serch for tag or branch
while read -r LINE; do
  KEY=$(echo $LINE | awk -F':' '{print $1}' | tr -d "\'")
  VAL=$(echo $LINE | awk -F':' '{print $2}' | tr -d "\'")
  if [[ $KEY = vcs_path* ]]; then
    # Output tag or branch
    TAG_BRANCH=$(echo $VAL | tr -d ' ')
    # Check if tag/branch is not empty.
    if [[ -n $TAG_BRANCH ]]; then
      echo $TAG_BRANCH
      exit
    fi
  fi
done <<< "$OUTPUT"

exit 1
