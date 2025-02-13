#!/bin/bash

# @HoangDH - Jun 29 2019
# set -ex

ENV_FILE="/etc/ssl-expiry-checker-slack.env"

get_env_value() {
    local k=$1
    echo $(awk -F= -v key="$k" '$1==key { print $2 }' $ENV_FILE)
}

WEBHOOK=$(get_env_value "WEBHOOK")
SLACK_CHANNEL=$(get_env_value "SLACK_CHANNEL")
NOTIFICATION_DAYS=$(get_env_value "NOTIFICATION_DAYS")
SLACK_BOTNAME="SSL Checker"

notify() {

  DOMAIN="$1"
  EXPIRY_DAYS="$2"
  EXPIRY_DATE="$3"
  ISSUER="$4"
  COLOR="$5"

  SLACK_PAYLOAD="payload={\"channel\":\"${SLACK_CHANNEL}\",\"icon_emoji\":\":skull:\",\"username\":\"${SLACK_BOTNAME}\",\"attachments\":[{\"color\":\"${COLOR}\",\"fields\":[{\"title\":\"Domain:\",\"value\":\"${DOMAIN}\",\"short\":true},{\"title\":\"Expiry day(s):\",\"value\":\"${EXPIRY_DAYS}\",\"short\":true},{\"title\":\"Expiry date:\",\"value\":\"$EXPIRY_DATE\",\"short\":true},{\"title\":\"Issued by:\",\"value\":\"$ISSUER\",\"short\":true}]}]}"
  curl -X POST --data-urlencode "$SLACK_PAYLOAD" $WEBHOOK
}

check_certs() {
  if [ -z "$1" ]
  then
    echo "Domain name missing"
    exit 1
  fi
  name="$1"
  shift

  now_epoch=$( date +%s )
  ip_server=$(dig +short a $name)
  dig +noall +answer +short $name | while read -r ip;
  do
    if [ "$ip" == "$ip_server" ]
    then
      data=`echo | openssl s_client -showcerts -servername $name -connect $ip:443 2>/dev/null | openssl x509 -noout -enddate -issuer`
      expiry_date=$(echo $data | grep -Eo "notAfter=(.*)GMT" | cut -d "=" -f 2)
      issuer=$(echo $data | grep -Eo "CN=(.*)"| cut -d "=" -f 2)
      expiry_epoch=$(date -d "$expiry_date" +%s)
      expiry_days="$(( ($expiry_epoch - $now_epoch) / (3600 * 24) ))"
      if [[ $expiry_days -lt $NOTIFICATION_DAYS ]];
      then
          color="#ff0000"
          notify "$name" "$expiry_days" "$expiry_date" "$issuer" "$color"
      fi
    fi
  done
}

check_certs $1
