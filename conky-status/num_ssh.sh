#!/bin/bash
#users=$(ps aux | grep sshd: | cut -d\  -f1 | sort | uniq | grep -v root | tr '\n' ',' | sed 's/,$//')
users=$(ps aux | grep sshd | grep -v -e ^root -e grep | awk '{print $1}' | sort | uniq | tr '\n' ',' | sed 's/,$//')
#sessions=((`ps -A | grep sshd | wc -l`-1)/2)
sessions=$(((`pidof sshd | wc -w`-1)/2))
echo "$users ($sessions)"
