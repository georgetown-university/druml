#!/bin/sh

# Save script dir.
SCRIPT_DIR=$(cd $(dirname "$0") && pwd -P)

# Load includes.
source $SCRIPT_DIR/druml-inc-init.sh

# Display help.
if [[ ${#ARG[@]} -lt 2 || -z $PARAM_SITE || -n $PARAM_HELP ]]
then
  echo "usage: druml local-sitesync [--config=<path>] [--delay=<seconds>]"
  echo "                           [--site=<subsite> | --list=<list>]"
  echo "                           <environment from> <environment to>"
  exit 1
fi

# Load config.
source $SCRIPT_DIR/druml-inc-config.sh

# Read parameters.
SUBSITE=$PARAM_SITE
ENV_FROM=$(get_environment ${ARG[1]})
ENV_TO=$(get_environment ${ARG[2]})
DRUSH_ALIAS_FROM=$(get_drush_alias $ENV_FROM)
DRUSH_ALIAS_TO=$(get_drush_alias $ENV_TO)
SSH_ARGS=$(get_ssh_args $ENV_FROM)
DRUSH_SUBSITE_ARGS=$(get_drush_subsite_args $SUBSITE)

# Say Hello.
echo "=== Sync '$SUBSITE' DB from the $ENV_FROM to $ENV_TO ===" >&3
echo "" >&3

# Deploy databases.
echo "=== Sync databases" >&3
ssh -tn $SSH_ARGS "drush $DRUSH_ALIAS_FROM $DRUSH_SUBSITE_ARGS ac-database-copy $SUBSITE $ENV_TO"

echo "Database sync is scheduled." >&3
echo "" >&3

echo "Complete!" >&3
echo "" >&3
