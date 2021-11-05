#!/bin/bash

PRINTER_FILE="/etc/cups/printers.conf"

echo "do search and replace: $PRINTER_FILE"
perl -pi -e "s/PRINTER_PR40_HOST/$PRINTER_PR40_HOST/g" $PRINTER_FILE
perl -pi -e "s/PRINTER_PR42_HOST/$PRINTER_PR42_HOST/g" $PRINTER_FILE
perl -pi -e "s/PRINTER_PR43_HOST/$PRINTER_PR43_HOST/g" $PRINTER_FILE
perl -pi -e "s/PRINTER_PR44_HOST/$PRINTER_PR44_HOST/g" $PRINTER_FILE
perl -pi -e "s/PRINTER_PR47_HOST/$PRINTER_PR47_HOST/g" $PRINTER_FILE
perl -pi -e "s/PRINTER_PR48_HOST/$PRINTER_PR48_HOST/g" $PRINTER_FILE
perl -pi -e "s/PRINTER_PR49_HOST/$PRINTER_PR49_HOST/g" $PRINTER_FILE
perl -pi -e "s/PRINTER_PR50_HOST/$PRINTER_PR50_HOST/g" $PRINTER_FILE
perl -pi -e "s/PRINTER_PR60_HOST/$PRINTER_PR60_HOST/g" $PRINTER_FILE
perl -pi -e "s/PRINTER_PR62_HOST/$PRINTER_PR62_HOST/g" $PRINTER_FILE
perl -pi -e "s/PRINTER_TEST_HOST/$PRINTER_TEST_HOST/g" $PRINTER_FILE
echo "done"

exec "$@"