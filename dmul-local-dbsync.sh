#!/bin/sh

# Check parameters.
if [[ $# -lt 3 || $1 == "--help" ]]
then
  echo "This command synchronises a database from remote to local for a specific subsite."
  echo ""
  echo "Syntax: dmul local-dbsync [--config=dmul.yml] [--list=list | --site=subsite] <environment>"
  exit 1
fi

# Save script dir.
SCRIPT_DIR=$(cd $(dirname "$0") && pwd -P)

# Load includes.
source $SCRIPT_DIR/dmul-inc-init.sh

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
