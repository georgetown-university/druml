#!/bin/sh

if [ $# -lt 4 ]
then
  echo "This command performs arbitrary drush commands for a specific subsite."
  echo ""
  echo "Syntax: $0 <config> <subsite> <environment> <command 1> ... <command n>"
  echo "You can use following variables in a command:"
  echo " @SUBSITE - subsite machine name"
  echo " @DOCROOT - subsite docroot"
  echo " @LOG     - logs dir"
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
echo "=== Execute bash commands for '$SUBSITE' subsite on the $ENV environment"
echo "Commands to be executed:"

COMMANDS=""
while test ${#} -gt 0
do
  COMMANDS="$COMMANDS $1"
  shift
done

# Replace variables.
COMMANDS=${COMMANDS/@SUBSITE/$SUBSITE}
COMMANDS=${COMMANDS/@DOCROOT/$(get_remote_docroot $ENV)}
COMMANDS=${COMMANDS/@LOG/$(get_remote_log $ENV)}

# Output commands.
echo $COMMANDS
echo ""

# Execute drush commands
ssh -tn $SSH_ARGS "$COMMANDS"

echo ""
echo "Complete!"
echo ""
