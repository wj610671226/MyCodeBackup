#!/bin/bash
scp -P 3333 ./libReveal.* root@localhost:/Library/MobileSubstrate/DynamicLibraries/
scp -P 3333 ./mytools.cy root@localhost:/usr/lib/cycript0.9/
scp -P 3333 ./debugserver root@localhost:/usr/bin/debugserver
scp -P 3333 ./MJAppTools root@localhost:/usr/bin/MJAppTools