#!/bin/bash

##########

masterDocumentRoot=/var/www/vhosts/ms.<%= @host %>/www
copyDocumentRoot=/var/www/vhosts/<%= @host %>/www.copy
obsoletedDocumentRoot=/var/www/vhosts/<%= @host %>/www.obsolete

echo "Resetting file structure..."
if [ ! -f $copyDocumentRoot ];
then
    rm -rf $copyDocumentRoot
fi
cp -r $masterDocumentRoot $copyDocumentRoot

# Replace database credentials
file=$copyDocumentRoot/typo3conf/LocalConfiguration.php

searches=( "ms<%= @database %>" "<%= @password_master %>" )
replaces=( "<%= @database %>" "<%= @password %>" )

for (( c=0; c<=1; c++ ))
do
    cat $file | sed -s "s/${searches[$c]}/${replaces[$c]}/g" > $file.bak
    mv $file.bak $file
done

# Clear Cache
rm -rf $copyDocumentRoot/typo3temp/*

mv <%= @documentRoot %> $obsoletedDocumentRoot
mv $copyDocumentRoot <%= @documentRoot %>

##########
echo "Setting permission for installation..."
chown -R <%= @user %>:www-data <%= @documentRoot %>
#chmod -R 770 <%= @documentRoot %>/{fileadmin,typo3conf,typo3temp,uploads}

##########
echo "Restricting permission..."
chmod -R 750 <%= @documentRoot %>/typo3conf
chown -R root:www-data <%= @documentRoot %>/{fileadmin,typo3conf,uploads*}

##########
echo "Add additional configuration for preventing defacement"
cp /root/AdditionalConfiguration.php /var/www/vhosts/<%= @host %>/www/typo3conf/AdditionalConfiguration.php

##########
echo "Reset database..."
masterDatabase=ms<%= @database %>
masterDumpFile=/var/www/vhosts/ms.<%= @host %>/home/ms<%= @database %>.sql
if [ ! -f $masterDumpFile ];
then
    /usr/bin/mysqldump -u root -p<%= @password_root %> -e -Q  $masterDatabase > $masterDumpFile
fi

mysql -u root -p<%= @password_root %> -e "DROP DATABASE <%= @database %>; CREATE DATABASE <%= @database %>";
mysql -u root -p<%= @password_root %> <%= @database %> < $masterDumpFile;

#@todo update master password
#mysql -u root -p<%= @password_root %> -e "UPDATE be_users SET password='password' WHERE username='admin'";

##########
echo "Clean up..."
rm -rf $obsoletedDocumentRoot

echo "Script ended at `date +'%m/%d/%y @ %H:%M'`"
exit $?












##########
#echo "Adding 403 page..."
#cp /root/403.html <%= @documentRoot %>
#chmod 755 <%= @documentRoot %>/403.html

##########
#echo "Blocking website except from localhost..."

# Get public ip of server
#ip=`tail -n 1 /etc/hosts | awk '{print $1}'`
#echo "order deny,allow" >> <%= @documentRoot %>/.htaccess
#echo "deny from all" >> <%= @documentRoot %>/.htaccess
#echo "allow from $ip" >> <%= @documentRoot %>/.htaccess

##########
#echo "Allowing website to the world wide web..."
#head -n -3 <%= @documentRoot %>/.htaccess > <%= @documentRoot %>/.htaccess2 ; mv <%= @documentRoot %>/.htaccess2 <%= @documentRoot %>/.htaccess
