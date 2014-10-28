#!/bin/sh

# Set config parameter.
if [[ -z $PARAM_CONFIG ]]
then
  CONFIG="druml.yml"
else
  CONFIG=$PARAM_CONFIG
fi

# Find config.
set_config_path $(cd $(dirname "$CONFIG") && pwd -P)/$(basename "$CONFIG")
if [ ! -f $(get_config_path) ];
then
   echo "Config file '$CONFIG' does not exist."
   exit 1
fi

# Read config.
eval $(parse_yaml $(get_config_path) "conf_")
