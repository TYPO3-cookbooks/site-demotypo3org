#!/bin/bash

##########
echo "Downloading package and extract it..."
cd /tmp
wget http://get.typo3.org/<%= @packageName %> -O <%= @packageName %>.tgz
tar -xzf <%= @packageName %>.tgz
rm <%= @packageName %>.tgz

##########
echo "Resetting file structure..."
rm -rf <%= @documentRoot %>
mv <%= @packageName %>package* <%= @documentRoot %>

TABLES=$(mysql -u <%= @database %> -p<%= @password %> <%= @database %> -e 'show tables' | awk '{ print $1}' | grep -v '^Tables' )

##########
echo "Deleting tables from \"<%= @database %>\" database..."
for t in $TABLES
do
	mysql -u <%= @database %> -p<%= @password %> <%= @database %> -e "drop table $t"
done

##########
echo "Setting permission for installation..."
touch <%= @documentRoot %>/typo3conf/ENABLE_INSTALL_TOOL
chown -R <%= @user %>:www-data <%= @documentRoot %>
chmod -R 770 <%= @documentRoot %>/{fileadmin,typo3conf,typo3temp,uploads}

##########
echo "Blocking website except from localhost..."

# Get public ip of server
ip=`tail -n 1 /etc/hosts | awk '{ print $1}'`
echo "order deny,allow" >> <%= @documentRoot %>/.htaccess
echo "deny from all" >> <%= @documentRoot %>/.htaccess
echo "allow from $ip" >> <%= @documentRoot %>/.htaccess

##########
echo "Installing package..."
cd /var/www/vhosts/<%= @host %>/home/PackageInstaller; ./bin/behat features/install-<%= @packageName %>.feature

##########
echo "Enabling website to the world wide web..."
head -n -3 <%= @documentRoot %>/.htaccess > <%= @documentRoot %>/.htaccess2 ; mv <%= @documentRoot %>/.htaccess2 <%= @documentRoot %>/.htaccess

##########
echo "Restricting permission..."
chmod -R 750 <%= @documentRoot %>/typo3conf
