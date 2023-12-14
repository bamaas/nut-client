# Nut-client script

## Prerequisites

Root SSH access to the client.

## How to setup
1. Run install.sh

Provide the required config details.

## Troubleshooting

### Proxmox nut client
In case nut client can't be installed. Ensure correct apt repository sources are configured on the client side. 
correct /etc/apt/sources.list can be found at proxmox-apt-repos. After updating the file run `apt update`.


### Synology bug fix for nut server
DMS7 contains a bug that sends a FSD (force shutdown) signal to the slaves although the system is back on line power. (https://www.synoforum.com/threads/another-dsm7-regression-ups.6586/page-2)

To fix this perform the following: 
1. ssh into synology
2. vim /usr/syno/bin/synoups
3. Add at line 117: `AT ONLINE * CANCEL-TIMER waittimeup online`


Create a scheduled task, every minute, that executes the following:
`upsc ups@localhost | grep "FSD OL"; EXIT_CODE=$?;if [ $EXIT_CODE -eq 0 ]; then systemctl restart ups-usb.service; fi`

This will remove the FSD flag when the system is back on line power by performing a ups-usb service restart.
