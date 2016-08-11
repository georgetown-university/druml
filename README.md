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

USAGE
=====

With *Druml* you will be able to perform following commands:

* `local-sitesync` - synchronise a DB and files from a remote environment to a local one. Forget about editing hosts file, creating settings files, directories, resaving theme settings, or even logging in to a website - these routines are fully automated. Using this command you can also sync multiple sites at once.
  ```
  druml local-sitesync --site=mysite prod
  ```

* `remote-ac-sitesync` - synchronise a DB and files from one environment to another for a specific site or list of sites. It is an *Acquia Cloud* command.
  ```
  druml remote-ac-sitesync --list=newsites stg prod
  ```

* `remote-drush` -  run arbitrary *Drush* commands for a specific site or a list of sites running on a specific environment.
  ```
  druml remote-drush --list=all prod "rr" "updb -y" "fra -y" "cc all"
  ```

* `remote-php` - run a PHP script for a specific subsite without need to escape PHP code.
  ```
  druml remote-php --list=all --source=php/node-count.php --output=res/node-count.csv prod
  ```

* `remote-bash` - perform arbitrary bash commands on multiple servers.

Check `druml --help` or `druml <command> --help` for more info.

LISTS
-----

To perform a command for multiple sites you need to have sites grouped in a list. To run a command for a list of sites use `--list` parameter.

```
druml <command> --list=<listname> <arguments>
```

To decrease a load on a server while commands are beeing executed you can set delays between iterations. This can be done with a help of `--delay` parameter.

```
druml <command> --delay=<seconds> --list=<listname> <arguments>
```
To create a list of sites you need to update a configuration file and create a list file. You can also generate a list file automatically using `local-list` command. See [Configuration](#CONFIGURATION) section for more info.


CONFIGURATION
----
Before using Druml you need to have a configuration file, see [example.druml.yml](https://github.com/georgetown-university/druml/blob/master/example.druml.yml) as an example of it.


By default *Druml* loads configuration which is sotred in the `druml.yml` localted in the current directory. You can also specify path to the configuration file manually.
```
druml --config=~/supersite.yml <command> <arguments>
```

DEVELOPMENT
=====
This project is in active development, if you have any ideas or want to submit a bug, plese, check [issues](https://github.com/georgetown-university/druml/issues).
