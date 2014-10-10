#!/bin/sh

# Check parameters.
if [[ $# -lt 2 || $1 == "--help" ]]
then
  echo "This command executes an arbitrary dmul command"
  echo ""
  echo "Syntax: $0 <command> <config> [--list=list | --site=site] [--delay=delay] <argument 1> ... <argument 2>"
  exit 10
fi

# Read command.
COMMAND=$1
shift

# Save script dir.
SCRIPT_DIR=$(cd $(dirname "$0") && pwd -P)

# Load includes.
source $SCRIPT_DIR/dmul-inc-init.sh

# Read parameters.
LIST=""
DELAY=0
SITE=""
ARGUMENTS=""
shift

while test ${#} -gt 0
do
  _P_NAME=$(get_parameter_name $1)
  _P_VALUE=$(get_parameter_value $1)

  if [[ $_P_NAME == "list" ]]
  then
    LIST=$_P_VALUE
  elif [[ $_P_NAME == "delay" ]]
  then
    DELAY=$_P_VALUE
  elif [[ $_P_NAME == "site" ]]
  then
    SITE=$_P_VALUE
  else
    ARGUMENTS="$ARGUMENTS \"$1\"";
  fi
  shift
done


# Handle local-list command differently.
if [[ $COMMAND == "local-list" ]]
then
  echo "$(run_script $COMMAND $LIST $ARGUMENTS)"
  exit
fi


# Run commands for multiple subsites.
LISTFILE=$(get_list_file $LIST)
if [[ -f $LISTFILE ]]
then
  for SUBSITE in `cat $LISTFILE`
  do

    echo "$(run_script $COMMAND $SUBSITE $ARGUMENTS)"

    # Delay.
    if [[ $DELAY > 0 ]]
    then
      echo "Wait $DELAY seconds"
      sleep $DELAY
    fi

    echo ""
  done < $LISTFILE
else
  echo "$FILENAME file not found";
fi

# Run command for a single subsite.
if [[ -n $SITE ]]
then
  echo "$(run_script $COMMAND $SITE $ARGUMENTS)"
fi
