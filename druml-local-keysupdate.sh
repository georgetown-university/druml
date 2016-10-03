#!/bin/bash

# Get Druml dir.
SCRIPT_DIR=$1
shift

# Load includes.
source $SCRIPT_DIR/druml-inc-init.sh

# Display help.
if [[ ${#ARG[@]} -lt 1  || -n $PARAM_HELP ]]
then
  echo "usage: druml local-keysupdate [--config=<path>] <environment>"
  exit 1
fi

# Read parameters.
ENV=$(get_environment ${ARG[1]})

# Set variables.
KNOWN_HOSTS_FILE=$CONF_MISC_KNOWN_HOSTS
SERVER_COUNT=$(get_server_count $ENV)

# Perform KNOWN_HOSTS_FILE.
if [[ -f $KNOWNHOSTSFILE ]]
then
  echo "Known hosts file could not be found!"
  exit
fi

# Prepare list file.
touch $KNOWN_HOSTS_FILE;

I=0
while [ $I -lt $SERVER_COUNT ]
do
  REMOTE_HOST=$(get_remote_host $ENV $I)
  ssh-keyscan $REMOTE_HOST >> $KNOWN_HOSTS_FILE

  let I++
done
exit 0
