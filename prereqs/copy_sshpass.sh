#!/bin/sh
hosts=`cat hosts`
for i in $hosts;
do
  sshpass -p "cloudera" ssh-copy-id root@$i;
done
