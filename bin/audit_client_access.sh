#!/usr/bin/bash

# from svcplan-8540
# rxdebug -servers parchment -port 7000 -all | grep host | cut -f4 -d" " | sort | uniq | sed -e "s/,//g" | xargs -n 1 -iblah getent hosts blah
#

# Example: timeout 1 bash -c "cat < /dev/null > /dev/tcp/example.com/80"   

SERVERS=( cotton mylar paper parchment papyrus tyvek vellum )
SERVERS=( vellum )
PORTS=( 7000 7002 7003 7005 )
PORTS=( 7000 )

for server in "${SERVERS[@]}" ; do
  for port in "${PORTS[@]}" ; do
    echo "SERVER $server : $port"
    # timeout 1 cat < /dev/null > /dev/tcp/"${server}"/"${port}" || continue
    rxdebug -servers "${server}" -port "${port}" -all
  done
done \
| grep 'host' \
| cut -d' ' -f4 \
| cut -d, -f1 \
| sort -u \
| xargs -n 1 -iblah getent hosts blah
