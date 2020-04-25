#!/bin/bash
## 2020-04-25
## Small script to send notfiication over pushover about packages sent with lasership.com

WGET=`which wget`
CURL=`which curl`
P_KEY="your pushover key"
P_TOKEN="your pushover token"
LASER_URL="$LASER_URL"
COUNT=`$WGET -cq www.lasership.com/track/$LASER_URL/JSON -O - | jq '.Events|length'`
i=0

declare -a MESSAGE
while true; do
    OLD_COUNT=$COUNT
    NEW_COUNT=`$WGET -cq www.lasership.com/track/$LASER_URL/JSON -O - | jq '.Events|length'`
    if [ $OLD_COUNT -eq $NEW_COUNT ]; then
        MESSAGE+=`echo Date\&Time: `
	    MESSAGE+=`$WGET -cq www.lasership.com/track/$LASER_URL/JSON -O - | jq '.Events['0'].DateTime'|tr -d '"'`
        MESSAGE+=`echo "    "`
        MESSAGE+=`echo Location: `
	    MESSAGE+=`$WGET -cq www.lasership.com/track/$LASER_URL/JSON -O - | jq '.Events['0'].City'|tr -d '"'`
        MESSAGE+=`echo ", "`
	    MESSAGE+=`$WGET -cq www.lasership.com/track/$LASER_URL/JSON -O - | jq '.Events['0'].State'|tr -d '"'`
        MESSAGE+=`echo ", Status: "`
	    MESSAGE+=`$WGET -cq www.lasership.com/track/$LASER_URL/JSON -O - | jq '.Events['0'].EventType'|tr -d '"'`
        MESSAGE+=`echo "    "`
    fi
    echo "${MESSAGE[@]}"
            nohup curl -q -s \
              --form-string "token=$P_TOKEN" \
              --form-string "user=$P_KEY" \
              --form-string "message=${MESSAGE[@]}" \
              https://api.pushover.net/1/messages.json > /dev/null 2>&1 &

    STATUS=`$WGET -cq www.lasership.com/track/$LASER_URL/JSON -O - | jq '.Events['0'].EventType'|tr -d '"'`
    if [ "$STATUS" = "Delivered" ]; then
        exit 0
    fi
    sleep 10;
    COUNT=`$WGET -cq www.lasership.com/track/$LASER_URL/JSON -O - | jq '.Events|length'`
    unset MESSAGE

done



#declare -a MESSAGE
#while [[ $i -lt $COUNT ]]; do
#    MESSAGE+=`echo Date:`
#	MESSAGE+=`$WGET -cq www.lasership.com/track/$LASER_URL/JSON -O - | jq '.Events['$i'].DateTime'|tr -d '"'`
#    MESSAGE+=`echo "    "`
#    MESSAGE+=`echo Location: `
#	MESSAGE+=`$WGET -cq www.lasership.com/track/$LASER_URL/JSON -O - | jq '.Events['$i'].City'|tr -d '"'`
#    MESSAGE+=`echo ", "`
#	MESSAGE+=`$WGET -cq www.lasership.com/track/$LASER_URL/JSON -O - | jq '.Events['$i'].State'|tr -d '"'`
#    MESSAGE+=`echo ", Status:"`
#	MESSAGE+=`$WGET -cq www.lasership.com/track/$LASER_URL/JSON -O - | jq '.Events['$i'].EventType'|tr -d '"'`
#    MESSAGE+=`echo "    "`
#    ((i = i + 1))
#done
