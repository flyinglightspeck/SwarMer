#!/bin/bash

bash gen_conf_cluster_aws.sh
sleep 10

for i in {0..0}
do
  for j in {0..0}
  do
     echo "$i" "$j"
     bash start_cluster_aws.sh "$i"
     sleep 10
     pkill python3
  done
done
