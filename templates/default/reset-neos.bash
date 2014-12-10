#!/bin/bash

# Define variables
masterDocumentRoot=/var/www/vhosts/ms.<%= @host %>/www
copyDocumentRoot=/var/www/vhosts/<%= @host %>/www.copy
obsoletedDocumentRoot=/var/www/vhosts/<%= @host %>/www.obsolete # the next instance to be dropped.

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
echo "Setting permission for installation..."


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

# @todo flush cache
#mysql -u root -p<%= @password %> <%= @database %> -e "TRUNCATE table ";
#rm -rf <%= @document_root %>/typo3temp/Cache

##########
echo "Cleaning up..."
rm -rf $obsoletedDocumentRoot

echo "Script ended at `date +'%m/%d/%y @ %H:%M'`"
exit $?
