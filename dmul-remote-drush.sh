#!/bin/sh

# Save script dir.
SCRIPT_DIR=$(cd $(dirname "$0") && pwd -P)

# Load includes.
source $SCRIPT_DIR/dmul-inc-init.sh

# Display help.
if [[ ${#ARG[@]} -lt 2 || -z $PARAM_SITE || -n $PARAM_HELP ]]
then
  echo "usage: dmul remote-drush [--config=<path>] [--delay=<seconds>]"
  echo "                         [--site=<subsite> | --list=<list>]"
  echo "                         <environment> <commands>"
  exit 1
fi

# Load config.
echo $(load_config)

# Read parameters.
SUBSITE=$2
ENV=$(get_environment $3)
SSH_ARGS=$(get_ssh_args $ENV)
DRUSH_ALIAS=$(get_drush_alias $ENV)
shift && shift && shift

# Read variables and form commands to execute.
echo "=== Execute drush commands for '$SUBSITE' subsite on the '$ENV' environment"
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
