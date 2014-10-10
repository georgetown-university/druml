#!/bin/sh

if [ $# -lt 2 ]
then
  echo "This command generates file that lists all subsites."
  echo ""
  echo "Syntax: $0 <config> <list>"
  exit 1
fi

# Save script dir.
SCRIPT_DIR=$(cd $(dirname "$0") && pwd -P)

# Load includes.
source $SCRIPT_DIR/dmul-inc-init.sh

# Read parameters.
LISTFILE=$(get_list_file $2)
DOCROOT=$(get_docroot)

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

  if [[ "$SUBSITE" != "all" ]]
  then
    echo $SUBSITE >> $LISTFILE
  fi
done
