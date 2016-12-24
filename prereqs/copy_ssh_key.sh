#!/bin/sh

HOSTS=`cut -f 2 -d ' ' hosts.txt`

for HOST in $HOSTS
do
   cat ~/.ssh/id_rsa.pub | ssh root@$HOST 'mkdir -p .ssh && touch .ssh/authorized_keys && cat >> .ssh/authorized_keys && echo "Key copied"'
done
