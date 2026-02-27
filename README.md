# WayvrWalltaker
Let people share MSG into your wayvr overlay
<img width="994" height="1002" alt="image" src="https://github.com/user-attachments/assets/ffd65af5-156e-4ff8-ade8-c4125fcadad3" />



## Dependencies

- curl
- websocat
- sed
- bash
- jq
- date
- imagemagick
  
## Install
Copy all files to `$HOME/.config/wayvr/theme/gui`

<img width="286" height="480" alt="image" src="https://github.com/user-attachments/assets/fd2c2caf-d5d7-4f48-928c-0e1462b1e2c0" />

Then edit `$HOME/.config/wayvr/conf.d/panels.xml`
Add walltaker under custom panels
```
custom_panels:
  - "walltaker"
```
There will be an icon above you virtual keyboard, click it and toggle it being visible
Then move the window where you want it

## Configure
edit `$HOME/.config/wayvr/theme/gui/walltaker/walltakerconfig.sh`
change the 2 lines at the top
```
Link_ID <--- your id for the wallpaper you want changed
API_KEY <--- so you can respond to new images
```
All other values you dont need to change

The one optional one is `SERVICES`
Here you can add/remove programs/services.

This will tell WayvrWalltaker to wait for these programs/services to be up first before it connects to walltaker

It also watches these programs/services to see if they exited, then walltaker will cleanly exit.

## How to start/control

Start walltaker client by running `$HOME/.config/wayvr/theme/gui/walltaker/walltaker.sh`
I have it as a local plugin in envision

#### THERE IS NO NEED TO RUN THIS ONE MANUALLY
#### The wayvr window will call this script when interacted with
The other script `$HOME/.config/wayvr/theme/gui/walltaker/walltakerctl.sh`

Lets you do these actions via buttons at the bottom of the window

- Force Reload
- React with Came, Horny, Thanks, and Disgust

### Credits
Icons obtained via [SVGREPO](https://www.svgrepo.com/)
