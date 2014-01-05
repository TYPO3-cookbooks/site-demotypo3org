#!/bin/bash

##########
echo "Downloading distribution if necessary"

# Delete distribution if older than a day for saving bandwidth
find /tmp -type f -mtime +1 -name "<%= @distributionName %>.tgz" -exec rm {} \;

# Move to the temporary directory
cd /tmp

# If distribution file does not exist, download it.
if [ ! -f <%= @distributionName %>.tgz ];
then
    # Download distribution
    wget http://get.typo3.org/<%= @distributionName %> -O <%= @distributionName %>.tgz

    # Update time of the file
    touch <%= @distributionName %>.tgz
fi

##########
TABLES=$(mysql -u <%= @database %> -p<%= @password %> <%= @database %> -e 'show tables' | awk '{ print $1}' | grep -v '^Tables' )

echo "Deleting tables from \"<%= @database %>\" database..."
for t in $TABLES
do
	mysql -u <%= @database %> -p<%= @password %> <%= @database %> -e "drop table $t"
done

##########
echo "Extract distribution..."
cd /tmp
tar -xzf <%= @distributionName %>.tgz

##########
echo "Resetting file structure..."
rm -rf <%= @documentRoot %>
mv <%= @distributionName %>package* <%= @documentRoot %>

##########
echo "Adding 403 page..."
cp /root/403.html <%= @documentRoot %>
chmod 755 <%= @documentRoot %>/403.html

##########
echo "Blocking website except from localhost..."

# Get public ip of server
ip=`tail -n 1 /etc/hosts | awk '{ print $1}'`
echo "order deny,allow" >> <%= @documentRoot %>/.htaccess
echo "deny from all" >> <%= @documentRoot %>/.htaccess
echo "allow from $ip" >> <%= @documentRoot %>/.htaccess

##########
echo "Setting permission for installation..."
touch <%= @documentRoot %>/typo3conf/ENABLE_INSTALL_TOOL
chown -R <%= @user %>:www-data <%= @documentRoot %>
chmod -R 770 <%= @documentRoot %>/{fileadmin,typo3conf,typo3temp,uploads}

##########
echo "Installing distribution..."
cd /var/www/vhosts/<%= @host %>/home/PackageInstaller; ./bin/behat features/install-<%= @distributionName %>.feature

##########
echo "Allowing website to the world wide web..."
head -n -3 <%= @documentRoot %>/.htaccess > <%= @documentRoot %>/.htaccess2 ; mv <%= @documentRoot %>/.htaccess2 <%= @documentRoot %>/.htaccess

##########
echo "Add hook for preventing defacement"
cat /root/typo3-hook-tcemain.php >> /var/www/vhosts/<%= @host %>/www/typo3conf/AdditionalConfiguration.php

##########
echo "Restricting permission..."
chmod -R 750 <%= @documentRoot %>/typo3conf
chown -R root:www-data <%= @documentRoot %>/{fileadmin,typo3conf,uploads,typo3_src*}

echo "Script ended at `date +'%m/%d/%y @ %H:%M'`"
exit $?