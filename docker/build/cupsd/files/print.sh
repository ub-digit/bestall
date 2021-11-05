#!/bin/bash

FILESDIR="/apps/bestall/files"

#pdf2ps /apps/bestall/files/440074_pr44_20180112140648_487734b532da14b02681a3bb20d54f7d.pdf /tmp/test.ps && lp -d pr44 /tmp/test.ps

cd "$FILESDIR"

for file in *.pdf
do
    printername="$(echo $file | cut -d_ -f2)"
    pdf2ps "$file" "/tmp/$file.ps"
    lp -d "$printername" "/tmp/$file.ps"
    rm -f "/tmp/$file.ps"
    mkdir -p "done"
    mv "$file" "done/$file"
done

