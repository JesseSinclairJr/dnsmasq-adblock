#!/bin/bash

# pull Steven Black blocklist
wget --directory-prefix=/tmp/ https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts

# pull OISD blocklist
wget --directory-prefix=/tmp/ https://dbl.oisd.nl/basic

# sort out duplicate entries, though I expect none in the two lists I have currently
sort -u /tmp/basic /tmp/hosts > /tmp/blocklist

echo "LISTS PULLED"

# remove all comments
# if a line starts with a #, with any number of leading blanks, delete it ; then search for and delete all text including and after any # sounds
sed -i '/^[[:blank:]]*#/d;s/#.*//' /tmp/blocklist

# remove lines where the beginning and end of line are next to eachother (empty lines)
sed -i '/^$/d' /tmp/blocklist

# delete any lines referencing loopbacks
sed -i -e '/^127.0.0.1 /d;/::1/d' /tmp/blocklist

# remove the hosts file formatting that one these lists comes with
sed -i -e 's/^0.0.0.0 //' /tmp/blocklist

# remove any lines with just 0.0.0.0 on them
sed -i '/^[[:blank:]]*0.0.0.0[[:blank:]]*$/d' /tmp/blocklist

# add in dnsmasq blocklist formatting at the beginning and end of each blocklist entry
sed -i -e 's/^/address=\//;s/$/\//' /tmp/blocklist

echo "LISTS FULLY FORMATTED"

cat /tmp/blocklist > /etc/dnsmasq.d/hosts

echo "DNSMASQ ADDITIONAL HOSTS FILE UPDATED"

wc -l /etc/dnsmasq.d/hosts | tee

rm -f /tmp/blocklist /tmp/basic /tmp/hosts

echo "TEMPORARY FILES REMOVED"

systemctl restart dnsmasq.service

echo "DNSMASQ SERVICE RESTARTED"
