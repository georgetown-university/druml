#!/bin/bash

# Get Druml dir.
SCRIPT_DIR=$1
shift

# Load includes.
source $SCRIPT_DIR/druml-inc-init.sh

# Display help.
if [[ ${#ARG[@]} -lt 1 || -z $PARAM_SITE || -n $PARAM_HELP ]]
then
  echo "usage: druml remote-ac-olddbbackupsrm [--config=<path>] [--docroot=<path>]"
  echo "                                      [--jobs=<number>] [--delay=<seconds>]"
  echo "                                       --site=<subsite> | --list=<list>"
  echo "                                      [--days-old=<number>]"
  echo "                                      [--server=<number>]"
  echo "                                      <environment>"
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
DAYS_OLD=$PARAM_DAYS_OLD

if [[ $DAYS_OLD < 1 ]];  then
  DAYS_OLD=180
fi

# Say Hello.
echo "=== Remove old backups for '$SUBSITE' DB at the $ENV"
echo ""

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
NOW=$(date +%s)
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
      if [[ "$TYPE" = "ondemand" ]]; then
        ((DIFF = ($NOW - $STARTED) / 86400 ))
        if (( DIFF > $DAYS_OLD )); then
          echo "Removing on demand DB backup, ID=$ID."
          RM_OUTPUT=$(ssh -Tn $SSH_ARGS "$DRUSH $DRUSH_ALIAS ac-database-instance-backup-delete $SUBSITE $ID" 2>&1)
          RM_RESULT="$?"
          if [[ $? > 0 ]]; then
            echo "Error removing backup."
          fi
          if [[ $PARAM_DELAY > 0 ]];  then
            sleep $PARAM_DELAY
          fi
        fi
      fi
  fi
done <<< "$OUTPUT"