#!/bin/bash

# Get Druml dir.
SCRIPT_DIR=$(cd "$(dirname "$(test -L "$0" && readlink "$0" || echo "$0")")" && pwd)

# Get command.
COMMAND=$1
shift

# Load includes.
source "$SCRIPT_DIR/druml-inc-init.sh"

# Check if command exists
if [[ -n $COMMAND ]]
then
  EXISTS=$(script_exists $COMMAND)
  if [[ -z $EXISTS ]]
  then
    echo "Command '$COMMAND' does not exist!"
    exit 1
  fi
fi

# Display help.
if [[ -n $COMMAND && -n $PARAM_HELP ]]
then
  echo "$(run_script $COMMAND)"
  exit 1
elif [[ -z $COMMAND || -n $PARAM_HELP ]]
then
  echo "usage: druml [--help] [--config=<path>] [--docroot=<path>] <command> <arguments>"
  echo ""
  echo "Available commands are:"
  echo "  local-listupdate         Updates a list file that contains subsites"
  echo "  local-dbsync             Syncs a subsite DB from a remote env to a local one"
  echo "  local-samlsign           Signes SAML metadata file"
  echo "  local-sitesync           Syncs a subsite (DB and files) from a remote env to a"
  echo "                           local one"
  echo "  remote-ac-codedeploy     Deploys code from one environment to another"
  echo "  remote-ac-codepathdeploy Deployes a tag/branch to the specific enviornment"
  echo "  remote-ac-command        Executes any drush ac command"
  echo "  remote-ac-dbbackup       Backup a DB"
  echo "  remote-ac-dbsync         Syncs a subsite DB from one env to another"
  echo "  remote-ac-sitesync       Syncs a subsite (DB and fies) from one env to another"
  echo "  remote-ac-status         Waits until the task is completed"
  echo "  remote-ac-tagget         Returns tag or branch associated with environment"
  echo "  remote-bash              Performs arbitrary bash commands for a specific env"
  echo "  remote-drush             Performs arbitrary drush commands for a specific subsite"
  echo "  remote-filesync          Syncs subsite fies from one env to another"
  echo "  remote-memcacheflush     Syncs subsite fies from one env to another"
  echo "  remote-php               Performs a php code for a specific subsite"
  echo ""
  echo "See 'druml <command> --help' to read about a specific command."
  exit 1
fi

# Load config.
source $SCRIPT_DIR/druml-inc-config.sh

# Read parameters.
LIST=$PARAM_LIST
SITE=$PARAM_SITE

if [[ -n $PARAM_DELAY ]]
then
  DELAY=$PARAM_DELAY
else
  DELAY=0
fi

if [[ -n $PARAM_JOBS ]]
then
  JOBS=$PARAM_JOBS
else
  JOBS=1
fi

# Set variables.
DATETIME=$(date +%F-%H-%M-%S)

echo "=== Druml script started at $(date)"
echo ""

# Run commands for multiple subsites in multiple threads.
if [[ -n $LIST && "$COMMAND" != "local-listupdate" ]]
then
  iterate_script $LIST $JOBS $DELAY $DATETIME $COMMAND "${PROXY_PARAMS_ARGS[@]}"
  RESULT="$?"

  if [[ $RESULT > 0 ]]
  then
    echo "=== Druml script failed at $(date)"
    echo ""
    exit 1
  fi

  echo "=== Druml script ended successfully at $(date)"
  echo ""
  exit
fi

# Run command for a single subsite or other commands.
run_script $COMMAND "${PROXY_PARAMS_ARGS[@]}"
RESULT="$?"

if [[ $RESULT > 0 ]]
then
  echo "=== Druml script failed at $(date)"
  echo ""
  exit 1
fi

echo "=== Druml script ended successfully at $(date)"
echo ""
