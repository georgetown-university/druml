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
source $SCRIPT_DIR/dmul-inc-config.sh

# Read parameters.
SUBSITE=$PARAM_SITE
ENV=$(get_environment ${ARG[1]})
SSH_ARGS=$(get_ssh_args $ENV)
DRUSH_ALIAS=$(get_drush_alias $ENV)
shift && shift && shift

# Read commands to execute.
echo "=== Execute drush commands for '$SUBSITE' subsite on the '$ENV' environment"
echo "Commands to be executed:"

COMMANDS=""
I=1
for CMD in ${ARG[@]}
do
  if [[ $I -gt 1 && -n ${ARG[$I]} ]]
  then
    COMMANDS="$COMMANDS drush $DRUSH_ALIAS -l $SUBSITE ${ARG[$I]};"
    echo ${ARG[$I]}
  fi
  I=$((I+1))
done

echo ""

# Execute drush commands
ssh -tn $SSH_ARGS "$COMMANDS"

echo ""
echo "Complete!"
echo ""
