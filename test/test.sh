#!/bin/bash

# Test connection.
ssh -Tn drupal7druml.test@free-6255.devcloud.hosting.acquia.com "echo test connection"

# Remove druml log file
rm druml.cmd.log

# Requires bats to be installed.
bats test.bats 
