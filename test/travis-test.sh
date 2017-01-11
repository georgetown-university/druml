#!/bin/bash

# Test connection.
ssh -Tn drupal7druml.test@free-6255.devcloud.hosting.acquia.com "echo test connection"

cd test
../bats/bin/bats test.bats 