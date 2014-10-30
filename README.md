DESCRIPTION
=====

*Druml* is a Drupal multisite tool that helps to maintain multiple Drupal sites. It has been being developed in Georgetown University, which maintains over 250 Drupal websites.

*Druml* is a set of bash scripts. Despite the *Druml* sounds similar to *Drush*, it is not a replacement to *Drush*, instead it is an addition to *Drush* and it uses *Drush* a lot. It also fits nice to the *Acquia Cloud Platform* and there are some specific *Acquia Cloud* commands.

Interesting things about *Druml* is that it does not require you to have *Drush* installed on your local machine, though it should be installed on the remote server.

INSTALLATION
=====
1. Download recent Druml release.
2. Extract to `~/druml` directory.
3. Perform following commands in the terminal.
  ```
  echo 'alias druml="~/druml/druml.sh"' >> ~/.bash_profile
  source ~/.bash_profile
  ```

USAGE
=====
With *Druml* you will be able to perform following commands:

* `local-sitesync` - synchronise a DB and files from a remote env to a local one. Forget about editing hosts file, creating settings files and directories, resaving theme settings, or even logging in to a website, because everething is automated. With this command you can also sync multiple sites at once.
  ```
  druml local-sitesync --site=mysite prod
  ```

* `remote-ac-sitesync` - synchronise a DB and files from one environment to another for a specific site or list of sites.
  ```
  druml remote-ac-sitesync --list=newsites stg prod
  ```

* `remote-drush` -  run arbitrary drush commands for a specific site or list of sites running on a specific environment.
  ```
  druml remote-drush --list=default prod "rr" "updb -y" "fra -y" "cc all"
  ```

* `remote-php` - run php script for a specific subsite without need to escape PHP code.
  ```
  druml remote-php --list=default --source=php/node-count.php --output=res/node-count.csv prod
  ```

* `remote-bash` - perform arbitrary bash commands on multiple servers.

Check `druml --help` or `druml <command> --help` for more info.


CONFIGURATION
=====
By default *Druml* loads configuration which is sotred in the `druml.yml` localted in the current directory. You can also specify pass to the configuration file manually.
```
druml --config=~/supersite.yml
```
Before using Druml you need to have a configuration file, see [example.druml.yml](https://github.com/georgetown-university/druml/blob/master/example.druml.yml).


COMPARISON TO OTHER TOOLS
=====

There are several alternatives to *Druml*. In this section I will describe what can stop you from using them.

* `drush @sites` - it does not allow to control an order of commands execution, which could be required if you have important sites that you should process first. Also there is no way to have multiple groups of sites.
* [Automatic Drush Aliases](http://dropbucket.org/node/749) - though it is an interesting idea, it limits you to use `Drush` only, which means you still need to use `Druml` fpr certain tasks.
