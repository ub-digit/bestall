FROM olbat/cupsd 

COPY files/print.sh /apps/bestall/print.sh
COPY files/set_printer_hosts.sh /apps/bestall/set_printer_hosts.sh
COPY files/auto-enable-printer.sh /apps/bestall/auto-enable-printer.sh
COPY files/printers.conf /etc/cups/printers.conf


ENTRYPOINT ["/apps/bestall/set_printer_hosts.sh"]

CMD ["/usr/sbin/cupsd", "-f"]
