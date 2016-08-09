#!/bin/bash

# Get Druml dir.
SCRIPT_DIR=$1
shift

# Load includes.
source $SCRIPT_DIR/druml-inc-init.sh

# Display help.
if [[ ${#ARG[@]} -lt 2 || -n $PARAM_HELP ]]
then
  echo "usage: druml local-remote-ac-status [--config=<path>] [--docroot=<path>]"
  echo "                                    [--delay=<seconds>]"
  echo "                                    [--site=<subsite> | --list=<list>]"
  echo "                                    <environment> <task_id>"
  exit 1
fi

# Read parameters.
SUBSITE=$PARAM_SITE
ENV=$(get_environment ${ARG[1]})
TASK=$(get_environment ${ARG[2]})
DRUSH=$(get_drush_command)
DRUSH_ALIAS=$(get_drush_alias $ENV)
SSH_ARGS=$(get_ssh_args $ENV)
DRUSH_SUBSITE_ARGS=$(get_drush_subsite_args $SUBSITE)

# Check task status every 20 seconds during 10 minutes.
I=0;
while [ $I -lt 600 ]; do
  OUTPUT=$(ssh -Tn $SSH_ARGS "$DRUSH $DRUSH_ALIAS ac-task-info $TASK" 2>&1)
  RESULT="$?"

  while read -r LINE; do
    KEY=$(echo $LINE | awk '{print $1}')
    VAL=$( echo $LINE | awk '{print $3}')

    if [[ "$KEY" = "state" ]]; then
        STATE=$VAL
        if [[ "$STATE" = "done" ]]; then
          echo "Task completed."
          exit 0
        fi
        if [ "$STATE" != "waiting" -a "$STATE" != "started" -a "$STATE" != "received" ]; then
          echo "Task failed, state: $STATE."
          exit 1
        fi
    fi
  done <<< "$OUTPUT"
  let I=$I+20;
  sleep 20;
done

echo "Task failed beause of timeout, last state: $STATE."
exit 1
