DESCRIPTION
=====

*Druml* is a Drupal multisite tool that helps to maintain multiple Drupal sites. It has been developed in Georgetown University, which maintains over 250 Drupal websites.

*Druml* is a set of bash scripts. Despite the *Druml* sounds similar to *Drush*, it is not a replacement to *Drush*, instead it is an addition to *Drush* and it uses *Drush* a lot. It also works nice with *Acquia Cloud Platform* and there are some specific *Acquia Cloud* commands.

Interesting thing about *Druml* is that it does not require you to have *Drush* installed on your local machine, though it should be installed on the remote server.

FEATURES
-----
* Provides over 15 useful command wrappers for Drush, Bash, Memcache, SAML, Acquia Cloud.
* Allows to run any existing Drush commands chained in a batch.
* Runs commands either for multiple sites or individually.
* Allows to manage list of different sites and control execution priority.
* Allows to run commands in parallel threads.
* Could be extended with custom commands.
* Reads configuration from Yaml file.
* Installed easily.

ALTERNATIVES
-----

There are several alternatives to *Druml*, but they are not powerful as it is.

* `drush @sites` - nice and dirty workaround, though very limited.
* [Automatic Drush Aliases](http://dropbucket.org/node/749) - interesting approach but limited to Drush commands only, does not allow to run multiple commands in a chain or run them in parallel.

INSTALLATION
=====

Perform following code in the terminal:

  ```
  cd ~
  wget -qO- https://github.com/georgetown-university/druml/archive/master.zip | tar xvz && mv druml-master druml
  ln -s ~/druml/druml.sh /usr/local/bin/druml
  ```

EXAMPLES
=====

Here are some example of how you can use *Druml* in your deployment and development workflows.

* Performs multiple Drush commands for all sites running in 3 parallel jobs on production server.
  ```
  druml remote-drush prod --list=all --jobs=3 "rr" "updb -y" "fra -y" "cc all"
  ```

* Calculates amount of nodes for each site on prod, output result as a CSV file.
  ```
  druml remote-php prod --list=all --source=php/node-count.php --output=res/node-count.csv
  ```

* Copies DB and files of edited sites from stage environment to production in *Acuia Cloud*. This command also makes DB backup prior and flushes Memcache and Drupal cache after then execution.
  ```
  druml remote-ac-sitesync --list=edited stg prod
  ```
  
* Copies DB and files from a remote server to a local environment. This command also enabled development modules specified in the configuration.
  ```
  druml local-sitesync --site=mysite prod
  ```

AVAILABLE COMMANDS
-----
```
  local-listupdate         Updates a list file that contains subsites
  local-dbsync             Syncs a subsite DB from a remote env to a local one
  local-samlsign           Signes SAML metadata file
  local-sitesync           Syncs a subsite (DB and files) from a remote env to a
                           local one
  remote-ac-codedeploy     Deploys code from one environment to another
  remote-ac-codepathdeploy Deployes a tag/branch to the specific enviornment
  remote-ac-command        Executes any drush ac command
  remote-ac-dbbackup       Backup a DB
  remote-ac-dbsync         Syncs a subsite DB from one env to another
  remote-ac-sitesync       Syncs a subsite (DB and fies) from one env to another
  remote-ac-status         Waits until the task is completed
  remote-ac-tagget         Returns tag or branch associated with environment
  remote-bash              Performs arbitrary bash commands for a specific env
  remote-drush             Performs arbitrary drush commands for a specific subsite
  remote-filesync          Syncs subsite fies from one env to another
  remote-memcacheflush     Syncs subsite fies from one env to another
  remote-php               Performs a php code for a specific subsite
```
Check druml --help or druml <command> --help for more info.


LISTS
-----

* To perform a command for multiple sites you need to have sites grouped in a list. To run a command for a list of sites use `--list` parameter.
  ```
  druml <command> --list=<listname> <arguments>
  ```

* To decrease a load on a server while commands are being executed you can set delays between iterations. This can be done with a help of `--delay` parameter.
  ```
  druml <command> --delay=<seconds> --list=<listname> <arguments>
  ```

* To run commands for multiple sites in parallel user `--jobs` parameter.
  ```
  druml <command> --jobs=<number> --list=<listname> <arguments>
  ```

* To generate a list of all sites based on your *Drupal* installation run `local-listupdate` command. Prior to running this command youn eed to define `<listname>` in the configuration file.
  ```
  druml local-listupdate --docroot=<path to docroot> --list=<listname>
  ```
  
* You can also build your list manually and define in in the configuration file. See [Configuration](#CONFIGURATION) section for more info.

CONFIGURATION
-----
Before using Druml you need to have a configuration file, see [example.druml.yml](https://github.com/georgetown-university/druml/blob/master/example.druml.yml) as an example of it.


By default *Druml* loads configuration which is sotred in the `druml.yml` localted in the current directory. You can also specify path to the configuration file manually.
```
druml --config=~/supersite.yml <command> <arguments>
```

DEVELOPMENT
=====
This project is in active development, if you have any ideas or want to submit a bug, plese, check [issues](https://github.com/georgetown-university/druml/issues).
