#!/bin/bash
##StartConfig
MAIN_PID=$$
source $HOME/.config/wayvr/theme/gui/walltaker/walltakerconfig.sh
##EndConfig
##StartFunctions
#FALLBACK: called when server reports a failed fetch
on_fetch_failed() {
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
#SUCCESS: called when a clean update arrives
on_update() {
  local wall_json="$1"
  local wall_image=$(echo $wall_json | jq .post_url | sed 's/\"//g')
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
check_services_up(){
  local services=("$@")
  local walltaker_ready=false
  while [ "$walltaker_ready" == "false" ];
  do
    local x=0
    for f in ${services[@]};
    do
      local checkservice=$(pgrep -f "$f")
      if [ -n "$checkservice" ];then
        ((x++))
      fi
    done
    sleep 1
    if [ "$x" -eq "${#services[@]}" ];then
      local walltaker_ready=true
      sleep 3
    fi
  done
}
check_services_down(){
  local services=("$@")
  local x=0
  for f in ${services[@]}
  do
    local checkservice=$(pgrep -f "$f")
    if [ -z "$checkservice" ];then
        ((x++))
    fi
  done
  if [ "$x" -eq "${#services[@]}" ];then
      MONADO_DEAD=true
      kill -9 $(pgrep -f websocat) && kill "$MAIN_PID"
      sleep 2
      exit 0
  fi
}
##EndFunctions
#Start wait for services
check_services_up ${SERVICES[@]}
#a background kill script when specified services die
(
  while true; do
    sleep "$MSG_INT"
    check_services_down "${SERVICES[@]}"
  done
) &
#store the background pid and kill it when this script is dead
WATCHDOG_PID=$!
trap "kill $WATCHDOG_PID 2>/dev/null" EXIT
#Run failed fetch, to get the current image set
on_fetch_failed "$LINK_ID"
#PrepWebsocket
IDENTIFIER="{\"channel\":\"LinkChannel\",\"id\":${LINK_ID}}"
SUBSCRIBE_MSG="{\"command\":\"subscribe\",\"identifier\":\"$(echo "$IDENTIFIER" | sed 's/"/\\"/g')\"}"
[ "$VERBOSE" -ge 2 ] && echo "Connecting to: $WS_ENDPOINT"
[ "$VERBOSE" -ge 2 ] && echo "Subscribing to LinkChannel id=$LINK_ID"
[ "$VERBOSE" -ge 2 ] && echo ""
mkdir -p /tmp/waytaker
#EndPrepWebsocket

#StartWebsocket
(
  sleep 1
  echo "$SUBSCRIBE_MSG"
  sleep infinity
) | websocat --text "$WS://$DOMAIN/$WS_ENDPOINT" | while IFS= read -r line; do
  TYPE=$(echo "$line"    | jq -r '.type             // empty' 2>/dev/null)
  SUCCESS=$(echo "$line" | jq -r 'if .message.success == null then "" else (.message.success | tostring) end' 2>/dev/null)
  WHY=$(echo "$line"     | jq -r '.message.why      // empty' 2>/dev/null)

  case "$TYPE" in
    welcome)
      [ "$VERBOSE" -ge 2 ] && echo "[$(date '+%H:%M:%S')] WebSocket connected"
      ;;
    confirm_subscription)
      [ "$VERBOSE" -ge 2 ] && echo "[$(date '+%H:%M:%S')] Subscribed to LinkChannel id=$LINK_ID"
      ;;
    ping)
      [ "$VERBOSE" -ge 3 ] && echo "[$(date '+%H:%M:%S')] Heartbeat"
      ;;
    *)
      # No .type field this is a channel message (update or failure)
      if [ "$SUCCESS" = "true" ]; then
        MESSAGE_JSON=$(echo "$line" | jq '.message')
        echo "[$(date '+%H:%M:%S')] Success — id=$LINK_ID"
        on_update "$MESSAGE_JSON"
      elif [ "$SUCCESS" = "false" ]; then
        [ "$VERBOSE" -ge 1 ] && echo "[$(date '+%H:%M:%S')] Failed — id=$LINK_ID | reason: $WHY"
        on_fetch_failed "$LINK_ID"
      else
        # Unknown/unparseable message
        [ "$VERBOSE" -ge 3 ] && echo "[$(date '+%H:%M:%S')] Unknown: $line"
      fi
      ;;
  esac
done
#EndWebsocket
