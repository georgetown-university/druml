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
    $CONFIG_DIR/druml-${_SCRIPT}.sh $SCRIPT_DIR --config=$(get_config_path) "${@}"
    RESULT="$?"
  # Check for default command.
  elif [ -f "$SCRIPT_DIR/druml-${_SCRIPT}.sh" ];
  then
    $SCRIPT_DIR/druml-${_SCRIPT}.sh $SCRIPT_DIR --config=$(get_config_path) "${@}"
    RESULT="$?"
  fi

  # Eixt upon an error.
  if [[ $RESULT > 0 ]]; then
    return 1
  fi
}

# Run script and do not output immidiately.
run_script_stashed(){
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
  _COMMAND=${1}
  shift

  _LISTFILE=$(get_list_file $_LIST)
  if [[ -f $_LISTFILE ]]
  then
    _FAIL_FILE="$CONF_MISC_TEMPORARY/druml-list-failed-$TASK_ID"
    if [[ -f $_FAIL_FILE ]]
    then
      rm $_FAIL_FILE
    fi
    _I=0
    _COUNT=$(cat $_LISTFILE | grep . | wc -l | xargs)
    for _SUBSITE in `cat $_LISTFILE`
    do
      _PROXY_PARAM_SERVER="--server=$_I" # in get_ssh_args and other functions we will get division reminder by the server count
      sleep 0.02 && {
        _OUTPUT="$(run_script_stashed $_COMMAND --site=$_SUBSITE "${@}" $_PROXY_PARAM_SERVER)"
        _RESULT="$?"

        echo "$_OUTPUT"
        echo ""

        if [[ $_RESULT > 0 ]]
        then
          echo $_SUBSITE >> $_FAIL_FILE
        fi
      } &

      let _I+=1
      if ! (($_I % $_JOBS))
      then
        wait;

        if [ $_I -ne $_COUNT ]
        then
          echo "=== $_I / $_COUNT sites are done, iteration ended at $(date)"
        fi

        if [[ -f $_FAIL_FILE ]]
        then
          echo "Failed sites: $(cat $_FAIL_FILE | xargs | sed -e 's/ /, /g')."
          echo ""
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

    echo "=== $_I / $_COUNT sites are done, iteration ended at $(date)"
    # Return error if any of the sites failed
    if [[ -f $_FAIL_FILE ]]
    then
      echo "Failed sites: $(cat $_FAIL_FILE | xargs | sed -e 's/ /, /g')."
      echo ""
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

# Get servers count.
get_server_count() {
  _COUNT="CONF_SERVER_COUNT_${1}"
  echo "${!_COUNT}"
}

# Get SSH arguments.
get_ssh_args() {
  if [ -z $2 ]
  then
    _I=0
  else
    _SERVER_COUNT=$(get_server_count $1)
    _I=$(($2 % $_SERVER_COUNT))
  fi
  _V_HOST="CONF_SERVER_DATA_${1}_${_I}_HOST"
  _V_USER="CONF_SERVER_DATA_${1}_${_I}_USER"
  echo "${!_V_USER}@${!_V_HOST}"
}

# Get remote host.
get_remote_host() {
  if [ -z $2 ]
    then
    _I=0
  else
    _SERVER_COUNT=$(get_server_count $1)
    _I=$(($2 % $_SERVER_COUNT))
  fi
  _V_HOST="CONF_SERVER_DATA_${1}_${_I}_HOST"
  echo "${!_V_HOST}"
}

# Get remote docroot.
get_remote_docroot() {
  if [ -z $2 ]
  then
    _I=0
  else
    _SERVER_COUNT=$(get_server_count $1)
    _I=$(($2 % $_SERVER_COUNT))
  fi
  _V_ROOT="CONF_SERVER_DATA_${1}_${_I}_DOCROOT"
  echo "${!_V_ROOT}"
}

# Get remote log.
get_remote_log() {
  if [ -z $2 ]
  then
    _I=0
  else
    _SERVER_COUNT=$(get_server_count $1)
    _I=$(($2 % $_SERVER_COUNT))
  fi
  _V_LOG="CONF_SERVER_DATA_${1}_${_I}_LOG"
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

# Get param that could be proxied to another script.
get_param_proxy() {
  PARAM_VAR="PARAM_$(echo $1 | tr '[:lower:]' '[:upper:]')"
  if [[ -n ${!PARAM_VAR} ]]
  then
    echo "--$1=${!PARAM_VAR}"
  else
    echo ""
  fi
}

log_get_file() {
  LOG_FILE=""
  if [ -n ${CONF_MISC_LOG_DIR} ] && [ -n ${CONF_MISC_LOG_FILE} ]
  then
    if [ ! -d "${CONF_MISC_LOG_DIR}" ]
    then
      mkdir ${CONF_MISC_LOG_DIR}
    fi
    LOG_FILE="${CONF_MISC_LOG_DIR}/${CONF_MISC_LOG_FILE}"
  fi
  echo $LOG_FILE
}


# Log Druml command.
log_command() {
  _CONFIG_DIR=$(get_config_dir)

  LINE=$(echo $(hostname) $USER [$(date)] \"$_CONFIG_DIR\" \""${@}"\" started)

  LOG_FILE=$(log_get_file)
  if [[ -n ${LOG_FILE} ]]
  then
    echo $LINE >> ${LOG_FILE}
  fi
  if [[ -n ${CONF_MISC_LOG_EMAIL} ]]
  then
    mail -s "Druml script execution" $CONF_MISC_LOG_EMAIL <<< $LINE
  fi
}

# Log Druml command.
log_command_succeed() {
  _CONFIG_DIR=$(get_config_dir)

  LINE=$(echo $(hostname) $USER [$(date)] \"$_CONFIG_DIR\" \""${@}"\" succeed)

  LOG_FILE=$(log_get_file)
  if [[ -n ${LOG_FILE} ]]
  then
    echo $LINE >> ${LOG_FILE}
  fi
  if [[ -n ${CONF_MISC_LOG_EMAIL} ]]
    then
    mail -s "Druml script execution" $CONF_MISC_LOG_EMAIL <<< $LINE
  fi
}

# Log Druml command.
log_command_failed() {
  _CONFIG_DIR=$(get_config_dir)

  LINE=$(echo $(hostname) $USER [$(date)] \"$_CONFIG_DIR\" \""${@}"\" failed)

  LOG_FILE=$(log_get_file)
  if [[ -n ${LOG_FILE} ]]
  then
    echo $LINE >> ${LOG_FILE}
  fi
  if [[ -n ${CONF_MISC_LOG_EMAIL} ]]
    then
    mail -s "Druml script execution" $CONF_MISC_LOG_EMAIL <<< $LINE
  fi
}
