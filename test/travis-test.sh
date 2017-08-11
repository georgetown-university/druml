#!/bin/bash
cd test

# Test connection to the servers.
./test-connection.sh

# Run tests.
../bats/bin/bats test.bats 