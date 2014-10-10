#!/bin/sh

# Load includes.
source $SCRIPT_DIR/dmul-inc-yaml.sh
source $SCRIPT_DIR/dmul-inc-utils.sh

# Find config.
set_config_path $(cd $(dirname "$1") && pwd -P)/$(basename "$1")
if [ ! -f $(get_config_path) ];
then
   echo "Config file '$CONF' does not exist."
   exit 1
fi

# Read config.
eval $(parse_yaml $(get_config_path) "conf_")
