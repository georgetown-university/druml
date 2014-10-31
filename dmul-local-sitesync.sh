#!/bin/sh

# Save script dir.
SCRIPT_DIR=$(cd $(dirname "$0") && pwd -P)

# Load includes.
source $SCRIPT_DIR/dmul-inc-init.sh

# Display help.
if [[ ${#ARG[@]} -lt 1 || -z $PARAM_SITE || -n $PARAM_HELP ]]
then
  echo "usage: dmul local-sitesync [--config=<path>] [--delay=<seconds>]"
  echo "                           [--site=<subsite> | --list=<list>]"
  echo "                           <environment>"
  exit 1
fi

# Load config.
source $SCRIPT_DIR/dmul-inc-config.sh

# Read parameters.
SUBSITE=$PARAM_SITE
ENV=$(get_environment ${ARG[1]})

# Set variables.
SUBSITE_FILES="$(get_docroot)/sites/$SUBSITE/files"

# Say hello.
echo "=== Sync '$SUBSITE' subsite from the '$ENV' environment to the localhost"
echo "You may be pormted to enter a sudo password."
echo ""

# Add records to hosts file.
echo "=== Check subsite entry in the hosts file"
if ! grep -Fxq "127.0.0.1 $SUBSITE" $CONF_MISC_HOSTS
then
  while true; do
      echo "'127.0.0.1 $SUBSITE' entry is not present in $CONF_MISC_HOSTS"
      read -p "Do you want to add it (Y/N)?" answer
      case $answer in
          [Yy]* )
            sudo sh -c "echo '127.0.0.1 $SUBSITE' >> $CONF_MISC_HOSTS"
            echo "Done!"

            break;;
          [Nn]* )
            break;;
          * ) echo "Please answer yes or no.";;
      esac
  done
else
  echo "Entry exits."
fi
echo ""

# Prepare files dir.
echo "=== Prepare files directory"
if [ -d $SUBSITE_FILES ];
then
  sudo rm -rf $SUBSITE_FILES
fi
mkdir $SUBSITE_FILES
mkdir $SUBSITE_FILES/private
chmod -R a+rwx  $SUBSITE_FILES
echo "Done!"
echo ""

# TODO: sync files

# Sync db.
echo "$(run_script "local-dbsync" --site=$SUBSITE $ENV)"

echo "=== Prepare website for local development"
# Enable dev modules.
if [ -n $CONF_LOCAL_SYNC_ENABLE ]
then
  drush -r $(get_docroot) -l $SUBSITE en $CONF_LOCAL_SYNC_ENABLE -y
fi

# Disable prod modules.
if [ -n $CONF_LOCAL_SYNC_DISABLE ]
then
  drush -r $(get_docroot) -l $SUBSITE dis $CONF_LOCAL_SYNC_DISABLE -y
fi

# Clear cache.
drush -r $(get_docroot) -l $SUBSITE cc all

# Resave theme settings.
drush -r $(get_docroot) -l $SUBSITE php-eval "#
    module_load_include('inc', 'system', 'system.admin');
    foreach (array('at_georgetown') as \$theme_name) {
      \$form_state = form_state_defaults();
      \$form_state['build_info']['args'][0] = \$theme_name;
      \$form_state['values'] = array();
      drupal_form_submit('system_theme_settings', \$form_state);
    }
"

# Get login URL.
drush -r $(get_docroot) -l $SUBSITE uli
sudo chmod -R a+rwx $SUBSITE_FILES
echo "Complete!"
echo ""
