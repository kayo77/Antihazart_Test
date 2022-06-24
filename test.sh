#!/bin/bash

SERVER="smtp.example.com" #SMTP server for mail messages about test
FROM="addres_of_your_bot@example.com"
TO="first@example.com;second@example.com" #address of dns server admins
SUBJ="Antihazard Test"
MESSAGE=""
CHARSET="utf-8"
USER="addres_of_your_bot@example.com"
PASS="SMTP_password"
SRV="ip.ad.dr.es" #ip addres of DNS server
curl -k --silent -H "Accept: application/xml" -H "Content-Type: application/xml" -X GET https://hazard.mf.gov.pl/api/Register | \
     grep "AdresDomeny" | awk -F "<AdresDomeny>" '{print $2}' | \
     idn2 | awk -F "</adresdomeny>" '{print  $1 }' > hazard.zones
     
dig @$SRV +noall +answer -t A -f hazard.zones | awk '{print $1,$NF}' | grep -v '\.$' | grep -v 145.237.235.240 > results
rm -f hazard.zones

if [ -s results ] ; then
    MESSAGE="Test FAILED"
    sendemail -f $FROM -t $TO -u $SUBJ -s $SERVER -m $MESSAGE -v -o message-charset=$CHARSET -xu $USER -xp $PASS -a /root/scripts/results
else
    MESSAGE="Test OK"
    sendemail -f $FROM -t $TO -u $SUBJ -s $SERVER -m $MESSAGE -v -o message-charset=$CHARSET -xu $USER -xp $PASS 
fi
