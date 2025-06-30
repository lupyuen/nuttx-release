#!/usr/bin/env bash
## Power Avaota-A1 On or Off
## ./avaota-power on
## ./avaota-power off
echo "Now running https://github.com/lupyuen/nuttx-release/blob/main/avaota-power.sh $1"

set -e  ## Exit when any command fails

## First Parameter is on or off
state=$1
if [[ "$state" == "" ]]; then
  echo "ERROR: Specify 'on' or 'off'"
  exit 1
fi

## Get the Home Assistant Token, copied from http://localhost:8123/profile/security
## export HOME_ASSISTANT_TOKEN=xxxx
. $HOME/home-assistant-token.sh

## Set the Home Assistant Server
export HOME_ASSISTANT_SERVER=luppys-mac-mini.local:8123

echo "----- Power $state Avaota-A1"
curl \
    -X POST \
    -H "Authorization: Bearer $HOME_ASSISTANT_TOKEN" \
    -H "Content-Type: application/json" \
    -d "{\"entity_id\": \"automation.avaota_power_$state\"}" \
    http://$HOME_ASSISTANT_SERVER/api/services/automation/trigger
