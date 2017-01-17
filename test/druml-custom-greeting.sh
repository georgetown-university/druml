#!/bin/bash

# Get Druml dir.
SCRIPT_DIR=$1
shift

# Load includes.
source $SCRIPT_DIR/druml-inc-init.sh

# Display help.
if [[ ${#ARG[@]} -lt 1 || -z $PARAM_NAME || -n $PARAM_HELP ]]
then
  echo "usage: druml custom-greeting [--config=<path>] --name=name <greeting>"

  exit 1
fi

# Set variables.
GREETING=${ARG[1]}
NAME=$PARAM_NAME

echo "$GREETING $NAME!"