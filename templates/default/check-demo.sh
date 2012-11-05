#!/bin/bash

curl -s -L http://demo.typo3.org | grep -q "Powered by" || $(dirname $0)/reset-demo.sh
