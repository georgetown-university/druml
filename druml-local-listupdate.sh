#!/bin/bash

# Get Druml dir.
SCRIPT_DIR=$1
shift

# Load includes.
source $SCRIPT_DIR/druml-inc-init.sh

# Display help.
if [[ -z $PARAM_LIST || -n $PARAM_HELP ]]
then
  echo "usage: druml local-listupdate [--config=<path>] [--docroot=<path>] --list=<list>"
  exit 1
fi

# Read parameters.
LISTFILE=$(get_list_file $PARAM_LIST)

# Set variables.
DOCROOT=$(get_docroot)

# Perform validation.
if [[ -z $LISTFILE ]]
then
  echo "List file is not set!"
  exit
fi

# Prepare list file.
touch $LISTFILE; rm $LISTFILE; touch $LISTFILE

# Add records to the list file.
cd $DOCROOT/sites/
for i in $(ls -d */);
do
  SUBSITE=${i%%/}

  # Prevent from all sites directory and acquia dev desktop directories being otuputed.
  if [[ "$SUBSITE" != "all" &&  "$SUBSITE" != *".dd"* ]]
  then
    echo $SUBSITE >> $LISTFILE
  fi
done
