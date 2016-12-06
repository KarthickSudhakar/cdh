#!/bin/sh

#hosts=`cut -f 2 -d ' ' hosts_datalake.txt`
hosts=10.16.219.74
for host in $hosts
do
  scp deploy_prerequisites.sh root@$host:~
  ssh root@$host 'sh ~/deploy_prerequisites.sh'
  ssh root@$host 'rm -f ~/deploy_prerequisites.sh'
done
