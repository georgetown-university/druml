#!/bin/sh

if [ $# -lt 4 ]
then
  echo "This command performs arbitrary drush commands for a specific subsite."
  echo ""
  echo "Syntax: $0 <config> <subsite> <environment> \"<command 1>\" ... \"<command n>\""
  exit 1
fi

# Save script dir.
SCRIPT_DIR=$(cd $(dirname "$0") && pwd -P)

# Load includes.
source $SCRIPT_DIR/dmul-inc-init.sh

# Read parameters.
SUBSITE=$2
ENV=$(get_environment $3)
SSH_ARGS=$(get_ssh_args $ENV)
DRUSH_ALIAS=$(get_drush_alias $ENV)
shift && shift && shift

# Read variables and form commands to execute.
echo "=== Execute drush commands for '$SUBSITE' subsite on the $ENV environment"
echo "Commands to be executed:"

COMMANDS=""
while test ${#} -gt 0
do
  echo $1
  COMMANDS="$COMMANDS drush $DRUSH_ALIAS -l $SUBSITE $1;"
  shift
done
echo ""

# Execute drush commands
ssh -tn $SSH_ARGS "$COMMANDS"

echo ""
echo "Complete!"
echo ""
