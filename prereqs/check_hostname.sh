#!/bin/sh

HOSTS=`cut -f 2 -d ' ' hosts.txt`

for HOST in $HOSTS
do
   #echo $HOST
   #ssh root@$HOST 'hostname -f && hostname -s' >> hostnames.txt
   #ssh root@$HOST 'hostname -s' >> hostnames_sn.txt
   ssh root@$HOST 'hostname -f' >> hostnames_fqdn.txt
done

echo "done"
