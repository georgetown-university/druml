#!/bin/sh

# Load includes.
source $SCRIPT_DIR/dmul-inc-yaml.sh
source $SCRIPT_DIR/dmul-inc-utils.sh

# Read parameters

# Parse script parameters and arguments.
I=1
while test ${#} -gt 0
do
  _P_NAME=$(get_parameter_name $1)
  _P_NAME_U=$(echo $_P_NAME | tr '[:lower:]' '[:upper:]')
  _P_VALUE=$(get_parameter_value $1)

  if [[ -n $_P_NAME ]]
  then
    _PARAM_NAME="PARAM_${_P_NAME_U}"
    eval $_PARAM_NAME=$_P_VALUE
    PROXY_PARAMS="$PROXY_PARAMS --$_P_NAME=\"$_P_VALUE\"";
  else
    ARG[$I]=$1;
    if [[ $I>1 || `basename $0` != "dmul.sh" ]]
    then
      PROXY_ARGS="$PROXY_ARGS \"$1\""
    fi
    I=$I+1
  fi

  shift
done

# Display help
# TODO: add some help

# Set config parameter.
if [[ -z $PARAM_CONFIG ]]
then
  CONFIG="dmul.yml"
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
