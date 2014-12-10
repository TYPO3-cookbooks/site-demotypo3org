#!/bin/bash

# Security stop
echo "Remove me if you can!"
exit -1

# Define variables
composer="/usr/local/bin/composer"

##########
echo "Resetting file structure and database..."
rm -rf <%= @document_root %>
mysql -u root -p<%= @password_root %> -e "DROP DATABASE <%= @database %>; CREATE DATABASE <%= @database %> CHARACTER SET utf8 COLLATE utf8_general_ci";

##########
echo "Downloading distribution"
$composer create-project typo3/cms-base-distribution --stability <%= @stability %> --keep-vcs <%= @document_root %>
touch <%= @document_root %>/FIRST_INSTALL

##########
echo "Resetting file permission..."
chown -R <%= @user %>:www-data <%= @document_root %>

echo "Done!"
echo ""
echo "Next step is to enable Virtual Host:"
echo "ngxensite ms.<%= @domain %>; service nginx reload"
echo "http://ms.<%= @domain %>"
echo ""
echo "Pay attention chef-client will not work until:"
echo "ngxdissite ms.<%= @domain %>; service nginx reload"

exit $?
