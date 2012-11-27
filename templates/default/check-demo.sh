#!/bin/bash

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
    content=`curl -s -L http://demo.typo3.org | grep "Powered by"`
    if [ -z "$content" ]; then
        echo "Empty content for $i. Resetting website..."
        curl -s -L http://demo.typo3.org | grep -q "Powered by" || $(dirname $0)/reset-demo.sh
	    break
    fi
done
