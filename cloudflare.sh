#!/bin/bash
## change to data
user_email=""
token_key=""
zone_id=""
record_name=""

## Check  A record
record=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/${zone_id}/dns_records?type=A&name=${record_name}" \
    -H "X-Auth-Email: ${user_email}" \
    -H "X-Auth-Key: ${token_key}" \
    -H "Content-Type: application/json")
record_id=$(echo "$record" | sed -E 's/.*"id":"(\w+)".*/\1/')
echo $record_id
old_ip=$(echo "$record" | sed -E 's/.*"content":"(([0-9]{1,3}\.){3}[0-9]{1,3})".*/\1/')

## Check  IP Address
ip=$(curl -s https://api.ipify.org || curl -s https://ipv4.icanhazip.com/)
if [ "${ip}" == "" ]; then
  exit 1
fi
## check IP old != now
echo $ip
if [[ $ip == $old_ip ]]; then
    exit 0
fi

## ttl base 3600 proxy true
update=$(curl -X PATCH "https://api.cloudflare.com/client/v4/zones/${zone_id}/dns_records/${record_id}" \
     -H "X-Auth-Email: ${user_email}" \
     -H "X-Auth-Key: ${token_key}" \
     -H "Content-Type: application/json" \
     --data '{"type":"A","name":"'$record_name'","content":"'$ip'","ttl":3600,"proxied":true}')
