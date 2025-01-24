#!/bin/bash

# Put the API key configured for PowerDNS webserver/api
API_KEY="<API_KEY>"

# Strip only the top domain to get the zone id
DOMAIN=$(expr match "$CERTBOT_DOMAIN" '.*\.\(.*\..*\)')

# Get the zone id
ZONE_ID=$(curl -s -X GET "[put your protocol and domain of your PDNS API URL]/api/v1/servers/localhost/zones/$DOMAIN" \
     -H     "X-Api-Key: $API_KEY" \
     -H     "Content-Type: application/json" | python3 -c "import sys,json;print(json.load(sys.stdin)['id'])")

# Create TXT record
CREATE_DOMAIN="_acme-challenge.$CERTBOT_DOMAIN"
RECORD_ID=$(curl -s -X POST "[put your protocol and domain of your PDNS API URL]/api/v1/servers/localhost/zones/$ZONE_ID" \
     -H     "X-Api-Key: $API_KEY" \
     -H     "Content-Type: application/json" \
     --data '{ "rrsets": [{ "name": "'"$CREATE_DOMAIN"'",  "type": "TXT",  "ttl": 120,  "changetype": "REPLACE",  "records": [{ "content": "'"$CERTBOT_VALIDATION"'",  "disabled": false }] }] }'
# Save info for cleanup
if [ ! -d /tmp/CERTBOT_$CERTBOT_DOMAIN ];then
     mkdir -m 0700 /tmp/CERTBOT_$CERTBOT_DOMAIN
fi
echo $ZONE_ID > /tmp/CERTBOT_$CERTBOT_DOMAIN/ZONE_ID
echo $CREATE_DOMAIN > /tmp/CERTBOT_$CERTBOT_DOMAIN/RECORD_ID

# Sleep to make sure the change has time to propagate over to DNS
sleep 25