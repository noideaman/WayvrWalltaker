#!/bin/bash
##StartConfig
source $HOME/.config/wayvr/theme/gui/walltaker/walltakerconfig.sh
TEXT=$2
if [ -z '$TEXT' ]; then
    TEXT=""
fi
##EndConfig
##StartFunctions
#Manual Fetch of latest image
manual_fetch() {
  local link_id="$1"
  echo "using old api to get current image for id=$link_id"
  sleep 1
  local wall_json=$(curl -s https://$DOMAIN/$API_ENDPOINT/$link_id.json)
  local wall_image=$(echo $wall_json | jq .post_url | sed 's/\"//g')
  if [ -z "$wall_image" ] || [ "$wall_image" = "null" ]; then
    echo "  post_url still empty after retry, skipping"
    return 1
  fi
  local wall_poster=$(echo $wall_json | jq -r .set_by)
  local wall_file=$(echo $wall_json | jq -r .post_url | sed 's/^.*\///')
  [ "$wall_poster" = "null" ] || [ -z "$wall_poster" ] && wall_poster="Anon"
  rm -f /tmp/waytaker/UwU.png
  curl -s $wall_image -o /tmp/waytaker/$wall_file
  magick /tmp/waytaker/$wall_file -resize 1024x1024 -gravity center -background none -extent 1024x1024 /tmp/waytaker/UwU.png
  wayvrctl panel-modify $WAY_PANEL $WAY_IMAGE set-image /tmp/waytaker/UwU.png
  wayvrctl panel-modify $WAY_PANEL $WAY_POSTER set-text "Shared by $wall_poster"
  rm -f /tmp/waytaker/$wall_file
}

wall_response (){
local link_id="$1"
local api_key="$2"
local type="$3"
local text="$4"
if [ "$text" != "" ]; then
    curl -X POST "https://$DOMAIN/$API_ENDPOINT/$link_id/response.json" \
    -H "Content-Type: application/json" \
    -d '{
        "api_key": "'"$api_key"'",
        "type": "'"$type"'",
        "text": "'"$text"'"
    }' | jq
else
    curl -X POST "https://$DOMAIN/$API_ENDPOINT/$link_id/response.json" \
    -H "Content-Type: application/json" \
    -d '{
        "api_key": "'"$api_key"'",
        "type": "'"$type"'"
    }' | jq
fi
}

case "$1" in
    response_came)
        wall_response $LINK_ID $API_KEY came $TEXT
        ;;
    response_horny)
        wall_response $LINK_ID $API_KEY horny $TEXT
        ;;
    response_ok)
        wall_response $LINK_ID $API_KEY ok $TEXT
        ;;
    response_disgust)
        wall_response $LINK_ID $API_KEY disgust $TEXT
        sleep 3
        manual_fetch $LINK_ID
        ;;
    fetch)
        manual_fetch $LINK_ID
        echo fetch
        ;;
esac
