#!/bin/bash

# Test connection.
ssh -Tn gtowndc.prod@gtowndc.ssh.prod.acquia-sites.com "echo test connection"
ssh -Tn gtowndc.test@gtowndcstg.ssh.prod.acquia-sites.com "echo test connection"
ssh -Tn gtowndc.dev@gtowndcdev.ssh.prod.acquia-sites.com "echo test connection"

cd test
../bats/bin/bats test.bats 