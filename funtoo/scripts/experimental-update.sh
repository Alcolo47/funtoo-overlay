#!/bin/bash
eval `keychain --noask --eval id_dsa`  || exit 1
cd /root/funtoo-overlay
# get latest merge.py and friends
git pull || exit 1
/root/git/funtoo-overlay/funtoo/scripts/merge.py --branch master /var/git/experimental-2014 || exit 1
