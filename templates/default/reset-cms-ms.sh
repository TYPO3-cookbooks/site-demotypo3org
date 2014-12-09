#!/bin/bash

# Security stop
echo "Remove me if you can!"
exit -1

##########
echo "Resetting file structure..."
rm -rf <%= @document_root %>
mv /tmp/typo3_src* <%= @document_root %>
touch <%= @document_root %>/FIRST_INSTALL

##########
echo "Resetting file permission..."
chown -R <%= @user %>:www-data <%= @document_root %>

##########
echo "Resetting database..."
mysql -u root -p<%= @password_root %> -e "DROP DATABASE <%= @database %>; CREATE DATABASE <%= @database %>";


echo "Done!"
echo "Next step is to open http://ms.<%= @distribution_name %>.cms.typo3.org"

#TABLES=$(mysql -u <%= @database %> -p<%= @password %> <%= @database %> -e 'show tables' | awk '{ print $1}' | grep -v '^Tables' )
#
#echo "Deleting tables from \"<%= @database %>\" database..."
#for t in $TABLES
#do
#	mysql -u <%= @database %> -p<%= @password %> <%= @database %> -e "drop table $t"
#done

exit $?
