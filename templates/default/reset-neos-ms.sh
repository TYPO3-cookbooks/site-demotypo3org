#!/bin/bash

# Security stop
echo "Remove me if you can!"
exit -1

##########
echo "Downloading distribution if necessary"

# Delete distribution if older than a day for saving bandwidth
find /tmp -type d -mmin +1440 -name "<%= @distribution_name %>" | head -1 | xargs rm -rf

# Move to the temporary directory
cd /tmp

# If distribution file does not exist, download it.
if [ ! -d /tmp/<%= @distribution_name %> ];
then

    rm -f /tmp/composer.phar
    curl -s https://getcomposer.org/installer | php

    # Download distribution
    php /tmp/composer.phar --no-interaction create-project typo3/neos-base-distribution <%= @distribution_name %>

    # Update time of the file
    touch <%= @distribution_name %>
fi

##########

mysql -u root -p<%= @password_root %> -e "DROP DATABASE <%= @database %>; CREATE DATABASE <%= @database %>";

##########

echo "Resetting file structure and setting up permission..."
applicationPath=/var/www/vhosts/<%= @host %>/releases/current
rm -rf $applicationPath
cp -r /tmp/<%= @distribution_name %> $applicationPath

##########
echo "Setting up permission..."
# Prevent Flow "setfilepermissions" commmand error
# If directory does not exist a warning is raised.
mkdir $applicationPath/Web/_Resources
cd $applicationPath; sudo -u root FLOW_CONTEXT=Production ./flow flow:core:setfilepermissions <%= @user %> www-data www-data

# Check if that is really required
chmod -R 777 $applicationPath/Data

echo "Done!"
echo "Next step is to open http://ms.<%= @distribution_name %>.typo3.org/setup"

exit $?
