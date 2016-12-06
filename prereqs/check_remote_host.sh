#!/bin/sh

hosts=`cut -f 2 -d ' ' hosts.txt`
for host in $hosts
do
  scp prereq-check-single.sh root@$host:~
  ssh root@$host 'sh ~/prereq-check-single.sh' > rs/$host.txt
done
