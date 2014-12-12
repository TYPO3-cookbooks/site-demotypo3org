#!/bin/bash

# Security stop
echo "Remove me if you can!"
exit -1

# Define variables
composer="/usr/local/bin/composer"

##########
echo "Resetting file structure and setting up permission..."
applicationPath=/var/www/vhosts/<%= @host %>/releases/current
rm -rf $applicationPath
mysql -u root -p<%= @password_root %> -e "DROP DATABASE <%= @database %>; CREATE DATABASE <%= @database %> CHARACTER SET utf8 COLLATE utf8_general_ci";

##########
echo "Downloading distribution"
$composer create-project typo3/neos-base-distribution --stability <%= @stability %> --keep-vcs --no-dev $applicationPath

# Prevent Flow "setfilepermissions" commmand error
# If directory does not exist a warning is raised.
mkdir $applicationPath/Web/_Resources
cd $applicationPath; sudo -u root FLOW_CONTEXT=Production ./flow flow:core:setfilepermissions <%= @user %> www-data www-data

# Check if that is really required
chmod -R 777 $applicationPath/Data

##########
echo "Resetting file permission..."
chown -R <%= @user %>:www-data <%= @document_root %>

echo "Done!"
echo ""
echo "Next step is to enable Virtual Host:"
echo "ngxensite ms.<%= @domain %>; service nginx reload"
echo "http://ms.<%= @domain %>/setup"
echo ""
echo "Pay attention chef-client will not work until:"
echo "ngxdissite ms.<%= @domain %>; service nginx reload"

exit $?
