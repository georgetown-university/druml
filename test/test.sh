#!/bin/bash

# Remove druml log file
rm log/*

# Remove php script output file
rm output.txt

# Requires bats to be installed.
bats test.bats
