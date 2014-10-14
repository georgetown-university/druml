#!/bin/sh

# Check parameters.
if [[ $# -lt 1 || $# -eq 1 && $1 == "--help" ]]
then
  echo "This command executes an arbitrary dmul command"
  echo ""
  echo "Syntax: $0 <command> [--config=dmul.yml] [--list=list | --site=site] [--delay=delay] <argument 1> ... <argument 2>"
  exit 1
fi

# Save script dir.
SCRIPT_DIR=$(cd $(dirname "$0") && pwd -P)

# Load includes.
source $SCRIPT_DIR/dmul-inc-init.sh

# Read parameters.
COMMAND=${ARG[1]}
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
