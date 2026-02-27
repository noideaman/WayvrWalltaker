###StartConfig
##start walltaker values
#Link id for images
LINK_ID=CHANGEME!!!

#api key to respond to images
API_KEY=CHANGEME!!!

#websocket protocol
WS="wss"

#domain
DOMAIN="walltaker.joi.how"

#websocket endpoint
WS_ENDPOINT="cable"

#api endpoint
API_ENDPOINT="api/links"

# Verbosity level:
#   0 = successful updates only, 1 = successful + failed updates
#   2 = successful + failed + connection events (welcome, subscribed),3 = everything including heartbeat pings
VERBOSE=0
##end walltaker values


##start wayvr values
#check for monado/wayvr to make walltaker wait for
#startup and to exit websocat when done
SERVICES=("/usr/bin/wayvr" "/bin/monado-service")

#The name of the panel in wayvr
WAY_PANEL=walltaker
#The name of the image section in wayvr panel
WAY_IMAGE=UwU
#The name of the text section in wayvr WAY_PANNEL
WAY_POSTER=UwUPoster

#check for exiting while loop
MSG_INT=15
###EndConfig
