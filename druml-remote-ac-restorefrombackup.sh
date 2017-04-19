#!/bin/bash

# Get Druml dir.
SCRIPT_DIR=$1
shift

# Load includes.
source $SCRIPT_DIR/druml-inc-init.sh

# Display help.
if [[ ${#ARG[@]} -lt 1 || -z $PARAM_SITE || -n $PARAM_HELP ]]
then
  echo "usage: druml remote-ac-restorefrombackup [--config=<path>] [--docroot=<path>]"
  echo "                                         [--jobs=<number>] [--delay=<seconds>]"
  echo "                                         --site=<subsite> | --list=<list>"
  echo "                                         [--type=<ondemand|daily>]"
  echo "                                         [--server=<number>]"
  echo "                                         <environment>"
  exit 1
fi

# Read parameters.
SUBSITE=$(get_site_alias $PARAM_SITE)
ENV=$(get_environment ${ARG[1]})

# Set variables.
DRUSH=$(get_drush_command)
DRUSH_ALIAS=$(get_drush_alias $ENV)
SSH_ARGS=$(get_ssh_args $ENV $PARAM_SERVER)
DRUSH_SUBSITE_ARGS=$(get_drush_subsite_args $SUBSITE)
PROXY_PARAM_SERVER=$(get_param_proxy "server")
FILTER_TYPE=$PARAM_TYPE


# Say Hello.
echo "=== Restore '$SUBSITE' DB from backup on $ENV"
echo ""

if [[ $FILTER_TYPE != "" && $FILTER_TYPE != "ondemand" && $FILTER_TYPE != "daily" ]]; then
  echo "FILTER_TYPE parameter is not valid!"
  exit 1
fi

OUTPUT=$(ssh -Tn $SSH_ARGS "$DRUSH $DRUSH_ALIAS $DRUSH_SUBSITE_ARGS ac-database-instance-backup-list $SUBSITE" 2>&1)
RESULT="$?"
TASK=$(echo $OUTPUT | awk '{print $2}')

# Eixt upon an error.
if [[ $RESULT > 0 ]]; then
  echo "Error getting list of backups."
  exit 1
fi

ID=""
TYPE=""
STARTED=""
LATEST_ID=""
LATEST_STARTED=""
while read -r LINE; do
  KEY=$(echo $LINE | awk '{print $1}')
  VAL=$(echo $LINE | awk '{print $3}')

  if [[ "$KEY" = "id" ]]; then
    ID=$VAL
  fi
  
  if [[ "$KEY" = "type" ]]; then
    TYPE=$VAL
  fi

  if [[ "$KEY" = "started" ]]; then
    STARTED=$VAL

    if [[ $STARTED -ge $LATEST_STARTED ]]; then
      if [[ $FILTER_TYPE == "" || $FILTER_TYPE == $TYPE ]]; then
        LATEST_STARTED=$STARTED
        LATEST_ID=$ID
        LATEST_TYPE=$TYPE
      fi
    fi
  fi
done <<< "$OUTPUT"

if [[ $LATEST_ID == "" ]]; then
  echo "Backup has not been found!"
  exit 1
fi

echo "Restroting from $LATEST_TYPE DB backup, ID=$LATEST_ID, STARTED=$LATEST_STARTED."

R_OUTPUT=$(ssh -Tn $SSH_ARGS "$DRUSH $DRUSH_ALIAS ac-database-instance-backup-restore $SUBSITE $LATEST_ID" 2>&1)
R_RESULT="$?"
TASK=$(echo $OUTPUT | awk '{print $2}')

# Eixt upon an error.
if [[ $? > 0 ]]; then
  echo "Error removing backup."
fi
echo "$R_OUTPUT"
echo "Restoring from backup has been scheduled."

# Check task status.
run_script remote-ac-status $PROXY_PARAM_SERVER $ENV $TASK
if [[ $? > 0 ]]; then
  echo "Restoring from backup failed!"
  exit 1
fi

echo "Restoring from backup completed!"