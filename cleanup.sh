#!/bin/bash

# Get your API key from https://www.cloudflare.com/a/account/my-account
# PowerDNS configured API key
API_KEY="<API_KEY>"

if [ -f /tmp/CERTBOT_$CERTBOT_DOMAIN/ZONE_ID ]; then
    ZONE_ID=$(cat /tmp/CERTBOT_$CERTBOT_DOMAIN/ZONE_ID)
    rm -f /tmp/CERTBOT_$CERTBOT_DOMAIN/ZONE_ID
fi

if [ -f /tmp/CERTBOT_$CERTBOT_DOMAIN/RECORD_ID ]; then
    RECORD_ID=$(cat /tmp/CERTBOT_$CERTBOT_DOMAIN/RECORD_ID)
    rm -f /tmp/CERTBOT_$CERTBOT_DOMAIN/RECORD_ID
fi

# Remove the challenge TXT record from the zone
if [ -n "${ZONE_ID}" ]; then
    if [ -n "${RECORD_ID}" ]; then
        curl -s -X PATCH "[put your protocol and domain of your PDNS API URL]/api/v1/servers/localhost/zones/$ZONE_ID" \
            -H "X-Auth-Key: $API_KEY" \
            -H "Content-Type: application/json"
            --data '{ "rrsets": [{ "name": "'"$RECORD_ID"'",  "type": "TXT",  "changetype": "DELETE"}] }'
    fi
fi

#for my Ubuntu LTS server
#reload services to use the new generated certificates
#not sure if needed for apache but it works
systemctl reload apache2
#Restarting postfix should copy the new certificates to the chrooted folder postfix uses. 
#I just created a symlink on /var/spool/postfix/etc/letsencrypt/live/<mydomain> redirecting to /etc/letsencrypt/live/<mydomain>
systemctl restart postfix dovecot
