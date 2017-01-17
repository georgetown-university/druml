#!/bin/bash

# Get Druml dir.
SCRIPT_DIR=$1
shift

# Load includes.
source $SCRIPT_DIR/druml-inc-init.sh

# Display help.
if [[ ${#ARG[@]} -lt 1 || -n $PARAM_HELP ]]
then
  echo "usage: druml custom-echo [--config=<path>] <string>"

  exit 1
fi

# Set variables.
STRING=${ARG[1]}

echo "$STRING"