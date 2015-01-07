#!/bin/sh

# Save script dir.
SCRIPT_DIR=$(cd $(dirname "$0") && pwd -P)

# Load includes.
source $SCRIPT_DIR/druml-inc-init.sh

# Display help.
if [[ ${#ARG[@]} -lt 2 || -z $PARAM_SITE || -n $PARAM_HELP ]]
then
  echo "usage: druml remote-ac-sitesync [--config=<path>] [--delay=<seconds>]"
  echo "                               [--site=<subsite> | --list=<list>]"
  echo "                               <environment from> <environment to>"
  exit 1
fi

# Load config.
source $SCRIPT_DIR/druml-inc-config.sh

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
DRUSH_SUBSITE_ARGS=$(get_drush_subsite_args $SUBSITE)
FILES_DIR="$CONF_MISC_TEMPORARY/druml-files-${ENV_FROM}-${SUBSITE}-$(date +%F-%H-%M-%S)"
SSH_ARGS=$(get_ssh_args $ENV_FROM)

# Say Hello.
echo "=== Sync '$SUBSITE' subsite from the $ENV_FROM to $ENV_TO ===" >&3
echo "" >&3

# Deploy files.
echo "=== Sync files" >&3

# Copy files.
mkdir $FILES_DIR
scp -rp $SSH_ARGS_FROM:$DOCROOT_FROM/sites/$SUBSITE/files/ $FILES_DIR
ssh -tn $SSH_ARGS_TO "mkdir ${DOCROOT_TO}/sites/$SUBSITE/"
scp -rp $FILES_DIR/files $SSH_ARGS_TO:$DOCROOT_TO/sites/$SUBSITE
rm -rf $FILES_DIR
echo "Files are synced." >&3
echo "" >&3

# Deploy databases.
echo "=== Sync databases" >&3
ssh -tn $SSH_ARGS "drush $DRUSH_ALIAS_FROM $DRUSH_SUBSITE_ARGS ac-database-copy $SUBSITE $ENV_TO"

echo "Database sync is scheduled." >&3
echo "" >&3

echo "Complete!" >&3
echo "" >&3
