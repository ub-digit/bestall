#!/bin/bash

# Exit on error
set -e

if [[ -z "$1" ]]; then
    echo "Usage: $0 <target>"
    echo "<target> must be on of staging, lab or production"
    exit 0;
fi

targets="staging lab production"
target=$1

if [[ ! " $targets " =~ " $target " ]]; then
    echo "<target> must be on of staging, lab, prod or production"
    exit 1;
fi

./run-playbook.sh $target export-db
cp ./data/database.sql ../docker/postgres-initdb.d/database.sql

echo "Database dump has been copied to postgres-initdb.d directory"
