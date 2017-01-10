#!/bin/bash

eval `ssh-agentit`
./test/ssh.expect

cd test
../bats/bin/bats test.bats