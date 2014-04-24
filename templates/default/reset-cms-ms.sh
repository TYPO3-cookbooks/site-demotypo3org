#!/bin/bash

# Security stop
echo "Remove me if you can!"
exit -1

##########
echo "Downloading distribution if necessary"

# Delete distribution if older than a day for saving bandwidth
find /tmp -type f -mtime +1 -name "current.tgz" -exec rm {} \;

# Move to the temporary directory
cd /tmp

# If distribution file does not exist, download it.
if [ ! -f current.tgz ];
then
    # Download distribution
    wget http://get.typo3.org/current -O current.tgz

    # Update time of the file
    touch current.tgz
fi

##########
echo "Extract distribution..."
cd /tmp
tar -xzf current.tgz

##########
echo "Resetting file structure..."
rm -rf <%= @document_root %>
mv /tmp/typo3_src* <%= @document_root %>
touch <%= @document_root %>/FIRST_INSTALL

##########
mysql -u root -p<%= @password_root %> -e "DROP DATABASE <%= @database %>; CREATE DATABASE <%= @database %>";

#TABLES=$(mysql -u <%= @database %> -p<%= @password %> <%= @database %> -e 'show tables' | awk '{ print $1}' | grep -v '^Tables' )
#
#echo "Deleting tables from \"<%= @database %>\" database..."
#for t in $TABLES
#do
#	mysql -u <%= @database %> -p<%= @password %> <%= @database %> -e "drop table $t"
#done

exit $?

