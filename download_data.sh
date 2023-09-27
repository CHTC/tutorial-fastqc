#!/bin/bash

curl -L -o sub.tar.gz https://ndownloader.figshare.com/files/14418248
tar xvf sub.tar.gz
mv sub/* data/
rm sub.tar.gz
rm -r sub
