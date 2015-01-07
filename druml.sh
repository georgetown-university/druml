#!/bin/bash

# Save script dir.
SCRIPT_DIR=$(cd $(dirname "$0") && pwd -P)

# Load includes.
source $SCRIPT_DIR/druml-inc-init.sh

# Read command
COMMAND=${ARG[1]}

# Check if command exists
if [[ -n $COMMAND ]]
then
  EXISTS=$(script_exists $COMMAND)
  if [[ -z $EXISTS ]]
  then
    echo "Command '$COMMAND' does not exist!"
    exit
  fi
fi

# Display help.
if [[ -n $COMMAND && -n $PARAM_HELP ]]
then
  echo "$(run_script $COMMAND)"
  exit 1
elif [[ ${#ARG[@]} = 0 || -n $PARAM_HELP ]]
then
  echo "usage: druml [--help] [--config=<path>] <command> <arguments>"
  echo ""
  echo "Available commands are:"
  echo "  local-list          Updates a list file that contains subsites"
  echo "  local-dbsync        Syncs a subsite DB from a remote env to a local one"
  echo "  local-sitesync      Syncs a subsite (DB and files) from a remote env to a"
  echo "                      local one"
  echo "  remote-ac-dbsync    Syncs a subsite DB from one env to another"
  echo "  remote-ac-sitesync  Syncs a subsite (DB and fies) from one env to another"
  echo "  remote-bash         Performs arbitrary bash commands for a specific env"
  echo "  remote-drush        Performs arbitrary drush commands for a specific subsite"
  echo "  remote-php          Performs a php code for a specific subsite"
  echo ""
  echo "See 'druml <command> --help' to read about a specific command."
  exit 1
fi

# Load config.
source $SCRIPT_DIR/druml-inc-config.sh

# Read parameters.
LIST=$PARAM_LIST
SITE=$PARAM_SITE
DELAY=$PARAM_DELAY

# Handle local-list command differently.
if [[ $COMMAND == "local-list" ]]
then
  echo "$(run_script $COMMAND $PROXY_PARAMS $PROXY_ARGS)"
  exit
fi

# Run commands for multiple subsites.
if [[ -n $LIST ]]
then
  LISTFILE=$(get_list_file $LIST)
  if [[ -f $LISTFILE ]]
  then
    for SUBSITE in `cat $LISTFILE`
    do
      echo "$(run_script $COMMAND $PROXY_PARAMS --site=\"$SUBSITE\" $PROXY_ARGS)"

      # Delay.
      if [[ $DELAY > 0 ]]
      then
        echo "Wait $DELAY seconds"
        sleep $DELAY
      fi

      echo ""
    done < $LISTFILE
  else
    echo "$LISTFILE file not found";
  fi
  exit
fi

# Run command for a single subsite or other commands.
echo "$(run_script $COMMAND $PROXY_PARAMS $PROXY_ARGS)"
