#!/bin/bash

# Remove druml log file
rm log/*

# Remove php script output file
rm output.txt

# Test connection to the servers.
./test-connection.sh

# Run tests.
# Requires bats to be installed.
bats test.bats
