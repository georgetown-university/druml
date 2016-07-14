#!/bin/bash

# Load includes.
source $SCRIPT_DIR/druml-inc-yaml.sh
source $SCRIPT_DIR/druml-inc-utils.sh
source $SCRIPT_DIR/druml-inc-params.sh
source $SCRIPT_DIR/druml-inc-config.sh

# Make sure results are outputted immideately.
exec 2>&1
