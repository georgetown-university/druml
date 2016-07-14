#!/bin/bash

# Save script dir.
SCRIPT_DIR=$(cd $(dirname "$0") && pwd -P)

# Load includes.
source $SCRIPT_DIR/druml-inc-init.sh

# Display help.
if [[ ${#ARG[@]} -lt 1 || -n $PARAM_HELP ]]
then
  echo "usage: druml remote-flush-memcache [--config=<path>] [--docroot=<path>]"
  echo "                                   [--delay=<seconds>] <environment>"
  exit 1
fi

# Read parameters.
ENV=$(get_environment ${ARG[1]})
SSH_ARGS=$(get_ssh_args $ENV)
DRUSH_ALIAS=$(get_drush_alias $ENV)

# Read variables and form commands to execute.
echo "=== Flush memcache on the $ENV environment"
echo ""

DOCROOT=$(get_remote_docroot $ENV)

OUTPUT=$(ssh -Tn $SSH_ARGS "cd $DOCROOT && drush vget memcache_servers" 2>&1)
RESULT="$?"

# Eixt upon an error.
if [[ $RESULT > 0 ]]; then
  echo "Unable to get memcache servers";
  exit 1
fi

# Flush cache for each server.
COMMANDS="true"
while read -r LINE; do
  if [[ "$LINE" != "memcache_servers:" ]]; then
    SERVER=$(echo $LINE | awk -F':' '{print $1}' | tr -d "\'")
    PORT=$(echo $LINE | awk -F':' '{print $2}' | tr -d "\'")
    COMMANDS="$COMMANDS && /bin/echo -e 'flush_all\nquit' | nc -q1 $SERVER $PORT"
  fi
done <<< "$OUTPUT"
COMMANDS="$COMMANDS;"

# Execute commands.
OUTPUT=$(ssh -Tn $SSH_ARGS "$COMMANDS" 2>&1)
RESULT="$?"

# Eixt upon an error.
if [[ $RESULT > 0 ]]; then
  echo "Problem flushing cache, output:"
  echo "$OUTPUT"
  exit 1
fi

# Check flush status
while read -r LINE; do
  STATUS=$(echo $LINE | awk -F':' '{print $1}' | xargs)
  if [[ $STATUS != *"OK"* ]]; then
    echo "Problem flushing cache, output:"
    echo "$OUTPUT"
    exit 1
  fi
done <<< "$OUTPUT"

echo "Memcache has been flushed!"
exit 0
