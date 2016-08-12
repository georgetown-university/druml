#!/bin/bash

# Run script.
run_script(){
  # Get script name.
  _SCRIPT=${1}
  shift

  # Get script dir
  CONFIG_DIR=$(get_config_dir)

  # Check for custom command.
  if [ -f "$CONFIG_DIR/druml-${_SCRIPT}.sh" ];
  then
    OUTPUT=$($CONFIG_DIR/druml-${_SCRIPT}.sh $SCRIPT_DIR --config=$(get_config_path) "${@}")
    RESULT="$?"
  # Check for default command.
  elif [ -f "$SCRIPT_DIR/druml-${_SCRIPT}.sh" ];
  then
    OUTPUT=$($SCRIPT_DIR/druml-${_SCRIPT}.sh $SCRIPT_DIR --config=$(get_config_path) "${@}")
    RESULT="$?"
  fi

  # Echo script output.
  echo "$OUTPUT"

  # Eixt upon an error.
  if [[ $RESULT > 0 ]]; then
    return 1
  fi
}


# Iterate script for multiple sites.
iterate_script() {
  # Get parameters.
  _LIST=${1}
  shift
  _JOBS=${1}
  shift
  _DELAY=${1}
  shift
  _DATETIME=${1}
  shift
  _COMMAND=${1}
  shift


  _LISTFILE=$(get_list_file $_LIST)
  if [[ -f $_LISTFILE ]]
  then
    _FAIL_FILE="$CONF_MISC_TEMPORARY/druml-list-failed-$_DATETIME"
    _I=0
    _COUNT=$(cat $_LISTFILE | wc -l | xargs)
    for _SUBSITE in `cat $_LISTFILE`
    do
      let _I+=1;
      sleep 0.02 && {
        _OUTPUT="$(run_script $_COMMAND --site=$_SUBSITE "${@}")"
        _RESULT="$?"

        echo "$_OUTPUT"
        echo ""

        if [[ $_RESULT > 0 ]]
        then
          echo $_SUBSITE >> $_FAIL_FILE
        fi
      } &

      if ! (($_I % $_JOBS))
      then
        wait;

        echo "=== $_I / $_COUNT sites are done, iteration ended at $(date)"
        if [[ -f $_FAIL_FILE ]]
        then
          echo "Failed sites: $(cat $_FAIL_FILE | xargs | sed -e 's/ /, /g')."
          echo ""
          return 1
        fi

        # Delay.
        if [[ $_DELAY > 0 ]]
        then
          echo "Wait $_DELAY seconds"
          sleep $_DELAY
        fi
        echo ""
      fi;
    done < $_LISTFILE
    wait;

    # Return error if any of the sites failed
    if [[ -f $_FAIL_FILE ]]
    then
      return 1
    fi
  else
    echo "$_LISTFILE file not found";
    echo ""
    return 1
  fi
  echo ""
}

# Check if script exists.
script_exists() {
  _SCRIPT=${1}
  CONFIG_DIR=$(get_config_dir)

  # Check for custom command.
  if [ -f "$CONFIG_DIR/druml-${_SCRIPT}.sh" ];
  then
    echo 1
  # Check for default command.
  elif [ -f "$SCRIPT_DIR/druml-${_SCRIPT}.sh" ];
  then
    echo 1
  else
    echo ""
  fi
}

# Get a parameter name.
# For string "--parameter=value" returns "parameter".
get_parameter_name() {
  if [[ $1 == --* ]]
  then
    _STR=${1:2}
    OIFS="$IFS"
    IFS='='
    read -a _RET <<< "$_STR"
    IFS="$OIFS"
    echo ${_RET[0]}
  else
    echo ""
  fi
}

# Get a parameter value.
# For string "--parameter=value" returns "value".
get_parameter_value() {
  if [[ $1 == --* ]]
  then
    OIFS="$IFS"
    IFS='='
    read -a _RET <<< "$1"
    IFS="$OIFS"
    echo ${_RET[1]}
  else
    echo ""
  fi
}

# Get config path.
get_config_path() {
  echo $CONFIG_PATH
}

# Set config dir.
set_config_path() {
  CONFIG_PATH=$1
}

# Get config dir.
get_config_dir() {
  dirname $CONFIG_PATH
}

# Get docroot.
get_docroot() {
  if [[ -z $PARAM_DOCROOT ]]
  then
    echo $(get_config_dir)/$CONF_LOCAL_DOCROOT
  else
    echo $PARAM_DOCROOT
  fi
}

# Get real path of the dir relative to docroot
get_real_path_from_docroot_relative_path() {
  if [[ $1 == \/* ]] || [[ $1 == \~* ]];
  then
    echo $1
  else
    echo $(get_docroot)/$1
  fi
}

# Get and process ENV variable.
get_environment() {
  _ENV=$(echo $1 | tr '[:lower:]' '[:upper:]')
  _V_ALIAS="CONF_ENVIRONMENT_ALIAS_${_ENV}"
  if [ -n "${!_V_ALIAS}" ]
  then
    _ENV=$(echo ${!_V_ALIAS} | tr '[:lower:]' '[:upper:]')
  fi
  echo $_ENV
}

# Get SSH arguments.
get_ssh_args() {
  if [ -z $2 ]
  then
    I=0
  else
    I=$2
  fi
  _V_HOST="CONF_SERVER_DATA_${1}_${I}_HOST"
  _V_USER="CONF_SERVER_DATA_${1}_${I}_USER"
  echo "${!_V_USER}@${!_V_HOST}"
}

# Get remote docroot.
get_remote_docroot() {
  if [ -z $2 ]
  then
    I=0
  else
    I=$2
  fi
  _V_ROOT="CONF_SERVER_DATA_${1}_${I}_DOCROOT"
  echo "${!_V_ROOT}"
}

# Get remote log.
get_remote_log() {
  if [ -z $2 ]
  then
    I=0
  else
    I=$2
  fi
  _V_LOG="CONF_SERVER_DATA_${1}_${I}_LOG"
  echo "${!_V_LOG}"
}

# Get list file.
get_list_file() {
  _LIST=$(echo $1 | tr '[:lower:]' '[:upper:]')
  _V_LIST_FILE="CONF_LIST_${_LIST}"
  if [[ -n ${!_V_LIST_FILE} ]]
  then
    echo "$(get_config_dir)/${!_V_LIST_FILE}"
  else
    echo ""
  fi
}

# Get mysql arguments.
get_db_args() {
  if [[ -n ${CONF_LOCAL_DB_USER} ]]
  then
    ARGS="-u${CONF_LOCAL_DB_USER}"
  fi
  if [[ -n ${CONF_LOCAL_DB_PASS} ]]
  then
    ARGS="$ARGS -p${CONF_LOCAL_DB_PASS}"
  fi
  echo $ARGS
}

# Get drush alias.
get_drush_alias() {
  _V_DRUSH_ALIAS="CONF_DRUSH_ALIAS_${1}"
  echo "${!_V_DRUSH_ALIAS}"
}

# Get drush subsite.
get_drush_subsite_args() {
  if [ "$1" == "default" ]
  then
    echo ""
  else
    echo "-l $1"
  fi
}

# Get drush command.
get_drush_command() {
  if [[ -n ${CONF_DRUSH_COMMAND} ]]
  then
    echo ${CONF_DRUSH_COMMAND}
  else
    echo "drush"
  fi

}

# Get drush subsite.
get_local_db_name() {
  if [ "$1" == "default" ]
  then
    echo "${CONF_LOCAL_DB_PREFIX}${CONF_LOCAL_DB_DEFAULT}"
  else
    echo "${CONF_LOCAL_DB_PREFIX}$1"
  fi
}

# Strip first line in the file if it starts with 'tput'.
fix_file_tput() {
  FIRSTLINE=$(head -c 4 $1)
  if [ "$FIRSTLINE" == "tput" ]
  then
    tail -n +2 $1 > $1.tail
    mv -f $1.tail $1
  fi
}
