#!/bin/bash

# Save script dir.
SCRIPT_DIR=$(cd $(dirname "$0") && pwd -P)

# Load includes.
source $SCRIPT_DIR/druml-inc-init.sh

# Display help.
if [[ ${#ARG[@]} -lt 1 || -z $PARAM_SITE || -z $PARAM_SOURCE || -n $PARAM_HELP ]]
then
  echo "usage: druml remote-php [--config=<path>] [--docroot=<path>]"
  echo "                        [--delay=<seconds>]"
  echo "                        [--site=<subsite> | --list=<list>]"
  echo "                        --source=<path> [--output=<path>]"
  echo "                        <environment>"
  exit 1
fi

# Read parameters.
SUBSITE=$PARAM_SITE
ENV=$(get_environment ${ARG[1]})
SSH_ARGS=$(get_ssh_args $ENV)
DRUSH=$(get_drush_command)
DRUSH_ALIAS=$(get_drush_alias $ENV)
SOURCE=$(get_config_dir)/$PARAM_SOURCE
if [[ -n $PARAM_OUTPUT ]]
then
  OUTPUT_FILE=$(get_config_dir)/$PARAM_OUTPUT
fi
DRUSH_SUBSITE_ARGS=$(get_drush_subsite_args $SUBSITE)

# Read commands to execute.
echo "=== Execute php commands for '$SUBSITE' subsite on the '$ENV' environment"
echo "Commands to be executed:"

# Check if file exists.
if [ ! -f $SOURCE ];
then
   echo "File $SOURCE does not exist."
   exit 1
fi

# Read and proccess comamnds.
while read -r LINE
do
  echo "$LINE"

  # Strip comments
  # LINE=$(echo "$LINE" | sed 's/\#.*//g')
  # LINE=$(echo "$LINE" | sed 's/\/\/.*//g')

  CODE+=" "
  CODE+=$LINE
done < $SOURCE
echo ""

# Escape qoutes
CODE=${CODE//\'/\'\\\'\'}

# Execute php code.
COMMAND="$DRUSH $DRUSH_ALIAS $DRUSH_SUBSITE_ARGS php-eval '$CODE'"
OUTPUT=$(ssh -Tn $SSH_ARGS "$COMMAND" 2>&1)
RESULT="$?"

echo "Result:"
echo "$OUTPUT"

# Eixt upon an error.
# TODO: manually check uppon errors, because drush php-eval does not return 1
# exit code in case if there are PHP errors.
# See https://github.com/drush-ops/drush/issues/2223.
if [[ $RESULT > 0 ]]; then
  exit 1
fi

# Output result to the file.
if [[ -n $OUTPUT_FILE ]]
then
  echo "$OUTPUT" >> $OUTPUT_FILE
fi
