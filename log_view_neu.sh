#!/bin/bash

### Neueste Logdatei anzeigen:

ls -lt /var/log/system-updates/ | head -n 2
cat /var/log/system-updates/update_*.log

read -p "Drücke Return-Taste um zu schließen ..."