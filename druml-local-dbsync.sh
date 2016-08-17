#!/bin/bash

# Get Druml dir.
SCRIPT_DIR=$1
shift

# Load includes.
source $SCRIPT_DIR/druml-inc-init.sh

# Display help.
if [[ ${#ARG[@]} -lt 1 || -z $PARAM_SITE || -n $PARAM_HELP ]]
  then
  echo "usage: druml local-dbsync [--config=<path>] [--docroot=<path>]"
  echo "                          [--jobs=<number>] [--delay=<seconds>]"
  echo "                          --site=<subsite> | --list=<list>"
  echo "                          [--server=<number>]"
  echo "                          <environment>"
  exit 1
fi

# Read parameters.
SUBSITE=$PARAM_SITE
ENV=$(get_environment ${ARG[1]})

# Set variables.
SSH_ARGS=$(get_ssh_args $ENV $PARAM_SERVER)
DRUSH=$(get_drush_command)
DRUSH_ALIAS=$(get_drush_alias $ENV)
DRUSH_SUBSITE_ARGS=$(get_drush_subsite_args $SUBSITE)
DB_ARGS=$(get_db_args)
LOCAL_DB_NAME=$(get_local_db_name $SUBSITE)
DUMPFILE_SQL="$CONF_MISC_TEMPORARY/druml-${ENV}-${SUBSITE}-$(date +%F-%H-%M-%S).sql"
DUMPFILE_GZ="$DUMPFILE_SQL.gz"

# Say hello.
echo "=== Sync '$SUBSITE' DB from the '$ENV' environment to the localhost"

# Get db backup.
ssh $SSH_ARGS "$DRUSH $DRUSH_ALIAS $DRUSH_SUBSITE_ARGS sql-dump --skip-tables-key=common --gzip" > $DUMPFILE_GZ

# Extract db dump and impot into db.
gzip -dc < $DUMPFILE_GZ > $DUMPFILE_SQL

mysql $DB_ARGS -e "drop database if exists $LOCAL_DB_NAME"
mysql $DB_ARGS -e "create database $LOCAL_DB_NAME"

mysql $DB_ARGS $LOCAL_DB_NAME < $DUMPFILE_SQL

echo "Complete!"
echo ""
