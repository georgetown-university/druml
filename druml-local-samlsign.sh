#!/bin/bash

# Get Druml dir.
SCRIPT_DIR=$1
shift

# Load includes.
source $SCRIPT_DIR/druml-inc-init.sh

# Display help.
if [[ -n $PARAM_HELP ]]
then
  echo "usage: druml local-samlsign [--config=<path>] [--docroot=<path>]"
  exit 1
fi

# Get realpath
CONF_SAML_XMLSECTOOL=$(get_real_path_from_docroot_relative_path $CONF_SAML_XMLSECTOOL)
CONF_SAML_UNSIGNED=$(get_real_path_from_docroot_relative_path $CONF_SAML_UNSIGNED)
CONF_SAML_SIGNED=$(get_real_path_from_docroot_relative_path $CONF_SAML_SIGNED)
CONF_SAML_CRT=$(get_real_path_from_docroot_relative_path $CONF_SAML_CRT)
CONF_SAML_PEM=$(get_real_path_from_docroot_relative_path $CONF_SAML_PEM)

eval "$CONF_SAML_XMLSECTOOL --sign --inFile $CONF_SAML_UNSIGNED --outFile $CONF_SAML_SIGNED --certificate $CONF_SAML_CRT --key $CONF_SAML_PEM"
