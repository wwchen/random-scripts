#!/bin/bash
shopt -s extglob
# ${trimmed##*( )} for front
fan=$(sensors | grep RPM | grep -o '[0-9]* RPM ')
temp=$(sensors | grep temp1 | sed 's/.*+\(.*\).C/\1C/')
echo "${temp%%*( )} (${fan%%*( )})"
