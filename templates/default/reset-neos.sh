#!/bin/bash

##########
echo "Launching PhantomJS" daemon if stopped

pid=`ps -aefw | grep "phantomjs" | grep -v " grep " | awk '{print $2}'`
if [ -z "$pid" ]
then
    /usr/sbin/service phantomjs start
    echo '  -> service started';
fi

##########
echo "Downloading distribution if necessary"

# Delete distribution if older than a day for saving bandwidth
find /tmp -type d -mmin +1440 -name "<%= @distributionName %>" | head -1 | xargs rm -rf

# Move to the temporary directory
cd /tmp

# If distribution file does not exist, download it.
if [ ! -d <%= @distributionName %> ];
then

    rm -f /tmp/composer.phar
    curl -s https://getcomposer.org/installer | php

    # Download distribution
    php /tmp/composer.phar --no-interaction create-project typo3/neos-base-distribution neos

    # Update time of the file
    touch <%= @distributionName %>
fi

##########

mysql -u root -p<%= @password %> -e "DROP DATABASE <%= @database %>;"
mysql -u root -p<%= @password %> -e "CREATE DATABASE <%= @database %>;"
mysql -u root -p<%= @password %> -e "FLUSH PRIVILEGES;"

##########

echo "Resetting file structure and setting up permission..."
rm -rf <%= @currentRelease %>
cp -r <%= @distributionName %> <%= @currentRelease %>

##########
echo "Adding 403 page..."
cp /root/403.html <%= @documentRoot %>
chmod 755 <%= @documentRoot %>/403.html

##########
echo "Blocking website except from localhost..."

# Get public ip of server
ip=`tail -n 1 /etc/hosts | awk '{print $1}'`
echo "order deny,allow" >> <%= @documentRoot %>/.htaccess
echo "deny from all" >> <%= @documentRoot %>/.htaccess
echo "allow from $ip" >> <%= @documentRoot %>/.htaccess

##########
echo "Setting up permission..."
# Prevent Flow "setfilepermissions" commmand error
# If directory does not exist a warning is raised.
mkdir <%= @currentRelease %>/Web/_Resources
cd <%= @currentRelease %>; sudo -u root FLOW_CONTEXT=Production ./flow flow:core:setfilepermissions <%= @user %> www-data www-data

##########
echo "Building some cache which will make the installer faster..."
curl -s http://neos.demo.typo3.org/setup > /dev/null

# Building cache even deeper...
curl -s http://neos.demo.typo3.org/setup/login > /dev/null

##########
echo "Installing distribution..."
cd /var/www/vhosts/<%= @host %>/home/PackageInstaller; ./bin/behat features/install-<%= @distributionName %>.feature

##########
echo "Allowing website to the world wide web..."
head -n -3 <%= @documentRoot %>/.htaccess > <%= @documentRoot %>/.htaccess2 ; mv <%= @documentRoot %>/.htaccess2 <%= @documentRoot %>/.htaccess

echo "Script ended at `date +'%m/%d/%y @ %H:%M'`"

##########
echo "Stopping phantomjs"
/usr/sbin/service phantomjs stop
exit $?
