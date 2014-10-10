#!/bin/sh

if [ $# -lt 4 ]
then
  echo "This command syncs a subsite (db and fies) from one environment to another."
  echo ""
  echo "Syntax: $0 <config> <subsite> <environment from> <environment to>"
  exit 1
fi

# Save script dir.
SCRIPT_DIR=$(cd $(dirname "$0") && pwd -P)

# Load includes.
source $SCRIPT_DIR/dmul-inc-init.sh

# Read parameters.
SUBSITE=$2
ENV_FROM=$(get_environment $3)
ENV_TO=$(get_environment $4)
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
