#!/bin/bash

# Save script dir.
SCRIPT_DIR=$(cd $(dirname "$0") && pwd -P)

# Load includes.
source $SCRIPT_DIR/druml-inc-init.sh

# Display help.
if [[ ${#ARG[@]} -lt 2 || -z $PARAM_SITE || -n $PARAM_HELP ]]
then
  echo "usage: druml remote-ac-sitesync [--config=<path>] [--delay=<seconds>]"
  echo "                                [--site=<subsite> | --list=<list>]"
  echo "                                <environment from> <environment to>"
  exit 1
fi

# Load config.
source $SCRIPT_DIR/druml-inc-config.sh

SUBSITE=$PARAM_SITE
ENV_TO=$(get_environment ${ARG[2]})

# Copy files.
OUTPUT=$(run_script remote-filesync $PROXY_PARAMS $PROXY_ARGS 2>&1)
RESULT="$?"
echo "$OUTPUT"
if [[ $RESULT > 0 ]]; then
  exit 1
fi
echo ""

# Copy DB.
OUTPUT=$(run_script remote-ac-dbsync $PROXY_PARAMS $PROXY_ARGS 2>&1)
RESULT="$?"
echo "$OUTPUT"
if [[ $RESULT > 0 ]]; then
  exit 1
fi
echo ""

# Flush Memcache.
OUTPUT=$(run_script remote-flush-memcache $ENV_TO 2>&1)
RESULT="$?"
echo "$OUTPUT"
if [[ $RESULT > 0 ]]; then
  exit 1
fi
echo ""

# Flush Drupal cache.
OUTPUT=$(run_script remote-drush --site=$SUBSITE $ENV_TO "cc all" 2>&1)
RESULT="$?"
echo "$OUTPUT"
if [[ $RESULT > 0 ]]; then
  exit 1
fi
