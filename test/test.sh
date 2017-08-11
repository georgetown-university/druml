#!/bin/bash

# Test connection.
ssh -Tn gtowndc.prod@gtowndc.ssh.prod.acquia-sites.com "echo test connection"
ssh -Tn gtowndc.test@gtowndcstg.ssh.prod.acquia-sites.com "echo test connection"
ssh -Tn gtowndc.dev@gtowndcdev.ssh.prod.acquia-sites.com "echo test connection"

# Remove druml log file
rm log/*

# Remove php script output file
rm output.txt

# Requires bats to be installed.
bats test.bats
