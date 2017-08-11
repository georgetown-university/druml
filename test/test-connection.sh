# Update SSH keys.
../druml.sh local-keysupdate prod
../druml.sh local-keysupdate stg
../druml.sh local-keysupdate dev

# Perform test connections.
../druml.sh remote-bash prod "echo yo yo yo"
sleep 5
../druml.sh remote-bash stg "echo yo yo yo"
sleep 5
../druml.sh remote-bash dev "echo yo yo yo"
sleep 5