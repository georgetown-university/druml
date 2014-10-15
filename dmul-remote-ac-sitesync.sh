#!/bin/sh

# Save script dir.
SCRIPT_DIR=$(cd $(dirname "$0") && pwd -P)

# Load includes.
source $SCRIPT_DIR/dmul-inc-init.sh

# Display help.
if [[ ${#ARG[@]} -lt 2 || -z $PARAM_SITE || -n $PARAM_HELP ]]
then
  echo "usage: dmul remote-ac-sitesync [--config=<path>] [--delay=<seconds>]"
  echo "                               [--site=<subsite> | --list=<list>]"
  echo "                               <environment from> <environment to>"
  exit 1
fi

# Load config.
source $SCRIPT_DIR/dmul-inc-config.sh

# Read parameters.
SUBSITE=$PARAM_SITE
ENV_FROM=$(get_environment ${ARG[1]})
ENV_TO=$(get_environment ${ARG[2]})
SSH_ARGS_FROM=$(get_ssh_args $ENV_FROM)
SSH_ARGS_TO=$(get_ssh_args $ENV_TO)
DOCROOT_FROM=$(get_remote_docroot $ENV_FROM)
DOCROOT_TO=$(get_remote_docroot $ENV_TO)
DRUSH_ALIAS_FROM=$(get_drush_alias $ENV_FROM)
DRUSH_ALIAS_TO=$(get_drush_alias $ENV_TO)
FILES_DIR="$CONF_MISC_TEMPORARY/dmul-files-${ENV_FROM}-${SUBSITE}-$(date +%F-%H-%M-%S)"

# Say Hello.
echo "=== Sync '$SUBSITE' subsite from the $ENV_FROM to $ENV_TO ==="
echo ""

# Deploy files.
echo "=== Deploy files"

# Copy files.
mkdir $FILES_DIR
scp -rp $SSH_ARGS_FROM:$DOCROOT_FROM/sites/$SUBSITE/files/ $FILES_DIR
ssh -tn $SSH_ARGS_TO "mkdir ${DRUSH_ALIAS_TO}/sites/$SUBSITE/"
scp -rp $FILES_DIR/files $SSH_ARGS_TO:$DOCROOT_TO/sites/$SUBSITE
rm -rf $FILES_DIR
echo "Files are deployed."
echo ""

# Deploy databases.
echo "=== Deploy databases"
drush $DRUSH_ALIAS_FROM -l $SUBSITE ac-database-copy $SUBSITE $ENV_TO
echo "Database deplpyment is scheduled."
echo ""

echo "Complete!"
echo ""
