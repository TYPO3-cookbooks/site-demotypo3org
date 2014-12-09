#!/bin/bash

home=$(dirname $0)
log="/var/log/demo"

if [ ! -d $log ];
then
    mkdir $log
fi

# configured page
links=(
    "/"
)
for i in "${links[@]}"
do
    content=`curl -s -L http://introduction.cms.demo.typo3.org$i | grep "Powered by"`
    if [ -z "$content" ]; then
        echo "Empty content for $i. Resetting website..."
        $home/introduction.cms.demo.typo3.org.reset.bash

        # Log incident
        fileName=keep-alive-incident-`date +"%m-%d-%y-%T"`
        logFile=$log/$fileName
        echo "${i}" > $logFile
        echo "" >> $logFile
        echo "" >> $logFile
        echo "${content}" >> $logFile
        #<%= node[:zabbix][:install_dir] %>/bin/zabbix_sender --config <%= node[:zabbix][:etc_dir] %>/zabbix_agentd.conf --input-file $logFile
        break
    else
        echo "Check OK $i"
    fi
done
