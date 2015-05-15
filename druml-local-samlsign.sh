#!/bin/bash

# Save script dir.
SCRIPT_DIR=$(cd $(dirname "$0") && pwd -P)

# Load includes.
source $SCRIPT_DIR/druml-inc-init.sh

# Display help.
if [[ -n $PARAM_HELP ]]
then
  echo "usage: druml local-samlsign [--config=<path>]"
  exit 1
fi

# Load config.
source $SCRIPT_DIR/druml-inc-config.sh

# Read parameters.
DOCROOT=$(get_docroot)

eval "$CONF_SAML_XMLSECTOOL --sign --inFile $CONF_SAML_UNSIGNED --outFile $CONF_SAML_SIGNED --certificate $CONF_SAML_CRT --key $CONF_SAML_PEM"
