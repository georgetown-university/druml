#!/bin/sh

# Save script dir.
SCRIPT_DIR=$(cd $(dirname "$0") && pwd -P)

# Load includes.
source $SCRIPT_DIR/dmul-inc-init.sh

# Display help.
if [[ ${#ARG[@]} -lt 2 || -z $PARAM_SITE || -n $PARAM_HELP ]]
then
  echo "usage: dmul local-sitesync [--config=<path>] [--delay=<seconds>]"
  echo "                           [--site=<subsite> | --list=<list>]"
  echo "                           <environment from> <environment to>"
  exit 1
fi

# Load config.
source $SCRIPT_DIR/dmul-inc-config.sh

# Read parameters.
SUBSITE=$PARAM_SITE
ENV_FROM=$(get_environment ${ARG[1]})
ENV_TO=$(get_environment ${ARG[2]})

DRUSH_ALIAS_FROM=$(get_drush_alias $ENV_FROM)
DRUSH_ALIAS_TO=$(get_drush_alias $ENV_TO)

# Say Hello.
echo "=== Sync '$SUBSITE' DB from the $ENV_FROM to $ENV_TO ==="
echo ""

# Deploy databases.
echo "=== Deploy databases"
drush $DRUSH_ALIAS_FROM -l $SUBSITE ac-database-copy $SUBSITE $ENV_TO
echo "Database deplpyment is scheduled."
echo ""

echo "Complete!"
echo ""
