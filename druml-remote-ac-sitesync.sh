#!/bin/bash

# Get Druml dir.
SCRIPT_DIR=$1
shift

# Load includes.
source $SCRIPT_DIR/druml-inc-init.sh

# Display help.
if [[ ${#ARG[@]} -lt 2 || -z $PARAM_SITE || -n $PARAM_HELP ]]
then
  echo "usage: druml remote-ac-sitesync [--config=<path>] [--docroot=<path>]"
  echo "                                [--jobs=<number>] [--delay=<seconds>]"
  echo "                                --site=<subsite> | --list=<list>"
  echo "                                [--server=<number>]"
  echo "                                <environment from> <environment to>"
  exit 1
fi

# Read parameters.
SUBSITE=$PARAM_SITE
ENV_TO=$(get_environment ${ARG[2]})
PROXY_PARAM_SERVER=$(get_param_proxy "server")

# Backup target db.
run_script remote-ac-dbbackup --site=$SUBSITE $PROXY_PARAM_SERVER $ENV_TO
if [[ $? > 0 ]]; then
  exit 1
fi
echo ""

# Copy files.
run_script remote-filesync "${PROXY_PARAMS_ARGS[@]}"
if [[ $? > 0 ]]; then
  exit 1
fi
echo ""

# Copy DB.
run_script remote-ac-dbsync "${PROXY_PARAMS_ARGS[@]}"
if [[ $? > 0 ]]; then
  exit 1
fi
echo ""

# Flush Memcache.
run_script remote-memcacheflush $PROXY_PARAM_SERVER $ENV_TO
if [[ $? > 0 ]]; then
  exit 1
fi
echo ""

# Flush Drupal cache.
run_script remote-drush --site=$SUBSITE $PROXY_PARAM_SERVER $ENV_TO "cc all"
if [[ $? > 0 ]]; then
  exit 1
fi

# TODO: Flush Varnish cache.
