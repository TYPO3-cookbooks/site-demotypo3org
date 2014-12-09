#!/bin/bash

# Security stop
echo "Remove me if you can!"
exit -1

# Define variables
composer="/usr/local/bin/composer"

##########
echo "Resetting file structure and database..."
rm -rf <%= @document_root %>
mysql -u root -p<%= @password_root %> -e "DROP DATABASE <%= @database %>; CREATE DATABASE <%= @database %>";

##########
echo "Downloading distribution"
$composer create-project typo3/cms-base-distribution <%= @document_root %>
touch <%= @document_root %>/FIRST_INSTALL

##########
echo "Resetting file permission..."
chown -R <%= @user %>:www-data <%= @document_root %>

echo "Done!"
echo "Next step is to enable Virtual Host:"
echo "ngxensite ms.introduction.cms.demo.typo3.org"
echo "Open the browser:"
echo "http://ms.<%= @distribution_name %>.cms.demo.typo3.org"
echo "Pay attention chef-client will not work until:"
echo "ngxdissite ms.<%= @distribution_name %>.cms.demo.typo3.org"

exit $?
