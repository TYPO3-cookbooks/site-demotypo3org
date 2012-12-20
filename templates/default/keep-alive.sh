#!/bin/bash

home=$(dirname $0)
log="/var/log/app"

if [ ! -d $log ];
then
    mkdir $log
fi

links=(
    "/"
    "/about-typo3/history/"
    "/about-typo3/community/"
    "/features/"
    "/customizing-typo3/"
    "/resources/"
    "/resources/consultancies/"
    "/resources/documentation/"
    "/resources/typo3-association/"
    "/examples/languages-characters/"
    "/examples/text/"
    "/examples/headers/"
    "/examples/text-and-images/"
    "/examples/images-with-links/"
    "/examples/image-groups/"
    "/examples/image-effects/"
    "/examples/tables/"
    "/examples/frames/"
    "/examples/lists/"
    "/examples/file-downloads/"
    "/examples/forms/"
    "/examples/news/"
    "/examples/site-map/"
    "/feedback/"
)
for i in "${links[@]}"
do
    content=`curl -s -L http://demo.typo3.org$i | grep "Powered by"`
    if [ -z "$content" ]; then
        echo "Empty content for $i. Resetting website..."
        $home/reset-demo.sh

        # Log incident
        fileName=keep-alive-incident-`date +"%m-%d-%y-%T"`
        logFile=$log/$fileName
        echo "${i}" > $logFile
        echo "" >> $logFile
        echo "" >> $logFile
        echo "${content}" >> $logFile
        break
    else
        echo "Check OK $i"
    fi
done
