#!/bin/sh

# Save script dir.
SCRIPT_DIR=$(cd $(dirname "$0") && pwd -P)

# Load includes.
source $SCRIPT_DIR/dmul-inc-init.sh

# Display help.
if [[ ${#ARG[@]} -lt 1 || -z $PARAM_SITE || -n $PARAM_HELP ]]
then
  echo "usage: dmul local-dbsync [--config=<path>] [--delay=<seconds>]"
  echo "                         [--site=<subsite> | --list=<list>]"
  echo "                         <environment>"
  exit 1
fi

# Load config.
source $SCRIPT_DIR/dmul-inc-config.sh

# Read parameters.
SUBSITE=$PARAM_SITE
ENV=$(get_environment ${ARG[1]})
SSH_ARGS=$(get_ssh_args $ENV)
DRUSH_ALIAS=$(get_drush_alias $ENV)
DB_ARGS=$(get_db_args)

# Generate temporary filenames.
DUMPFILE_SQL="$CONF_MISC_TEMPORARY/gudrupal-${ENV}-${SUBSITE}-$(date +%F-%H-%M-%S).sql"
DUMPFILE_GZ="$DUMPFILE_SQL.gz"

# Say hello.
echo "=== Sync '$SUBSITE' DB from the '$ENV' environment to the localhost"

# Get db backup.
ssh $SSH_ARGS "drush $DRUSH_ALIAS -l $SUBSITE sql-dump --skip-tables-key=common --gzip" > $DUMPFILE_GZ

# Extract db dump and impot into db.
gzip -dc < $DUMPFILE_GZ > $DUMPFILE_SQL
mysql -e "drop database if exists $SUBSITE"
mysql -e "create database $SUBSITE"

mysql $DB_ARGS $SUBSITE < $DUMPFILE_SQL

echo "Complete!"
echo ""
