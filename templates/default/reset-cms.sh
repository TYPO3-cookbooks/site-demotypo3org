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

mv <%= @document_root %> $obsoletedDocumentRoot
mv $copyDocumentRoot <%= @document_root %>

##########
echo "Adding additional configuration for preventing defacement"
cp /root/AdditionalConfiguration.php /var/www/vhosts/<%= @host %>/www/typo3conf/AdditionalConfiguration.php

##########
echo "Setting permission for installation..."
chown -R <%= @user %>:www-data <%= @document_root %>
#chmod -R 770 <%= @document_root %>/{fileadmin,typo3conf,typo3temp,uploads}

##########
echo "Restricting permission..."
chmod -R 750 <%= @document_root %>/typo3conf
chown -R root:www-data <%= @document_root %>/{fileadmin,typo3conf,uploads*}

##########
echo "Resetting database..."
masterDatabase=ms<%= @database %>
masterDumpFile=/var/www/vhosts/ms.<%= @host %>/ms<%= @database %>.sql
if [ ! -f $masterDumpFile ];
then
    /usr/bin/mysqldump -u root -p<%= @password_root %> -e -Q  $masterDatabase > $masterDumpFile
fi

mysql -u root -p<%= @password_root %> -e "DROP DATABASE <%= @database %>; CREATE DATABASE <%= @database %>";
mysql -u root -p<%= @password_root %> <%= @database %> < $masterDumpFile;

#@todo update master password
#mysql -u root -p<%= @password_root %> -e "UPDATE be_users SET password='password' WHERE username='admin'";

##########
echo "Cleaning up..."
rm -rf $obsoletedDocumentRoot

echo "Script ended at `date +'%m/%d/%y @ %H:%M'`"
exit $?












########## OBSOLETE CODE ##########
#echo "Adding 403 page..."
#cp /root/403.html <%= @document_root %>
#chmod 755 <%= @document_root %>/403.html

##########
#echo "Blocking website except from localhost..."

# Get public ip of server
#ip=`tail -n 1 /etc/hosts | awk '{print $1}'`
#echo "order deny,allow" >> <%= @document_root %>/.htaccess
#echo "deny from all" >> <%= @document_root %>/.htaccess
#echo "allow from $ip" >> <%= @document_root %>/.htaccess

##########
#echo "Allowing website to the world wide web..."
#head -n -3 <%= @document_root %>/.htaccess > <%= @document_root %>/.htaccess2 ; mv <%= @document_root %>/.htaccess2 <%= @document_root %>/.htaccess
