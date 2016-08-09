#!/bin/bash

# Get Druml dir.
SCRIPT_DIR=$1
shift

# Load includes.
source $SCRIPT_DIR/druml-inc-init.sh

# Display help.
if [[ ${#ARG[@]} -lt 2 || -z $PARAM_SITE || -n $PARAM_HELP ]]
then
  echo "usage: druml remote-filesync [--config=<path>]  [--docroot=<path>]"
  echo "                             [--delay=<seconds>]"
  echo "                             [--site=<subsite> | --list=<list>]"
  echo "                             <environment from> <environment to>"
  exit 1
fi

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
echo "=== Sync '$SUBSITE' files from $ENV_FROM to $ENV_TO"
echo ""

# Sync files.
mkdir $FILES_DIR 2>&1;
if [[ $? > 0 ]]; then
  echo "Can not create directory $FILES_DIR."
  exit 1
fi

rsync -a $SSH_ARGS_FROM:$DOCROOT_FROM/sites/$SUBSITE/files/ $FILES_DIR 2>&1
if [[ $? > 0 ]]; then
  echo "Can not sync files from $ENV_FROM."
  exit 1
fi

# ssh -Tn $SSH_ARGS_TO "mkdir ${DOCROOT_TO}/sites/$SUBSITE/"

rsync -a $FILES_DIR/* $SSH_ARGS_TO:$DOCROOT_TO/sites/$SUBSITE/files/ 2>&1
if [[ $? > 0 ]]; then
  echo "Can not sync files to $ENV_TO."
  exit 1
fi

rm -rf $FILES_DIR

echo "Files are synced!"
echo ""
