
printf "$SSH_KEY"
printf "$SSH_KEY_PUB"


printf "$SSH_KEY" > $HOME/.ssh/id_rsa
printf "$SSH_KEY_PUB" > $HOME/.ssh/id_rsa.pub

cat $HOME/.ssh/id_rsa
cat $HOME/.ssh/id_rsa.pub


sudo chmod a-w $HOME/.ssh/id_rsa
sudo chmod go-r $HOME/.ssh/id_rsa
sudo chmod a-w $HOME/.ssh/id_rsa.pub
sudo chmod go-r  $HOME/.ssh/id_rsa.pub

ssh -Tn drupal7druml.test@free-6255.devcloud.hosting.acquia.com "echo 123"

cd test
../bats/bin/bats test.bats 