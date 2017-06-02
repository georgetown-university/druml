#!/bin/bash

# Load includes.
source $SCRIPT_DIR/druml-inc-yaml.sh
source $SCRIPT_DIR/druml-inc-utils.sh
source $SCRIPT_DIR/druml-inc-params.sh
source $SCRIPT_DIR/druml-inc-config.sh

# Set unique task id.
TASK_ID="$(date +%F-%H-%M-%S)-$RANDOM"
