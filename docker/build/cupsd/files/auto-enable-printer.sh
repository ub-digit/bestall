#!/bin/bash

for i in $(lpstat -t | grep '^printer .* disabled since' | perl -pe 's/^printer (.*) disabled since.*/$1/')
do
    echo $(date): Reenabling printer $i
    /usr/sbin/cupsdisable "$i"
    /usr/sbin/cupsenable "$i"
done
