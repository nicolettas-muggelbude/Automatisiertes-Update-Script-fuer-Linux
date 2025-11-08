#!/bin/bash

### Letzte 50 Zeilen des neuesten Logs:

tail -n 50 /var/log/system-updates/$(ls -t /var/log/system-updates/ | head -n 1)

read -p "Drücke Return-Taste um zu schließen ..."