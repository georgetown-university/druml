#!/bin/sh

# Save script dir.
SCRIPT_DIR=$(cd $(dirname "$0") && pwd -P)

# Load includes.
source $SCRIPT_DIR/druml-inc-init.sh

# Display help.
if [[ ${#ARG[@]} -lt 1 || -z $PARAM_SITE || -z $PARAM_SOURCE || -n $PARAM_HELP ]]
then
  echo "usage: druml remote-php [--config=<path>] [--delay=<seconds>]"
  echo "                       [--site=<subsite> | --list=<list>]"
  echo "                       --source=<path> [--output=<path>]"
  echo "                       <environment>"
  exit 1
fi

# Load config.
source $SCRIPT_DIR/druml-inc-config.sh

# Read parameters.
SUBSITE=$PARAM_SITE
ENV=$(get_environment ${ARG[1]})
SSH_ARGS=$(get_ssh_args $ENV)
DRUSH_ALIAS=$(get_drush_alias $ENV)
SOURCE=$(get_config_dir)/$PARAM_SOURCE
if [[ -n $PARAM_OUTPUT ]]
then
  OUTPUT=$(get_config_dir)/$PARAM_OUTPUT
fi

# Read commands to execute.
echo "=== Execute php commands for '$SUBSITE' subsite on the '$ENV' environment" >&3
echo "Commands to be executed:" >&3

while read -r LINE
do
  echo $LINE >&3

  # Strip comments
  LINE=$(echo "$LINE" | sed 's/\#.*//g')
  LINE=$(echo "$LINE" | sed 's/\/\/.*//g')

  CODE+=" "
  CODE+=$LINE
done < $SOURCE
echo "" >&3

# Escape qoutes
CODE=${CODE//\'/\'\\\'\'}

# Execute php code.
echo "Result:" >&3
COMMAND="drush $DRUSH_ALIAS -l $SUBSITE php-eval '$CODE'"
RES=$(ssh $SSH_ARGS "$COMMAND")
echo $RES >&3

# Output results to the file.
if [[ -n $OUTPUT ]]
then
  echo $RES >> $OUTPUT
fi

echo "" >&3
echo "Complete!" >&3
echo "" >&3
