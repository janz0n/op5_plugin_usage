#!/usr/bin/env bash
# Fetch and count plugins used  by OP5 monitor
# Tested on CentOS6 and CentOS7.
# Enviroment with 30k services took approx 10sec runtime
# Creates op5_plugin_usage.csv

# --- Get plugins used and count ---
IFS=$'\n'
LIST=$(
for CMD in $(asmonitor mon query ls services -c check_command | cut -d '!' -f 1 | sort | uniq -c)
do
  # plugin connecteted to the check_command used by the service
  echo -n "$(asmonitor mon query ls commands -c line name -e $(echo $CMD | awk '{print $2}') | cut -d ' ' -f 1 | sed 's!.*/!!')"
  
  # add service count using the plugin 
  echo $CMD | awk '{printf " "$1"\n"}'
done
)

# --- Output as csv --- 
echo "PLUGIN,SVC_COUNT" > op5_plugin_usage.csv
# merge plugin fields and sum value in second field.
echo "$LIST" | awk '{arr[$1]+=$2;} END {for (i in arr) print i","arr[i]}' | sort -t, -n -r -k2 >> op5_plugin_usage.csv && echo "op5_plugin_usage.csv created successfully!"
