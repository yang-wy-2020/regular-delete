# regular-delete

> monitor&auto release useless file

## directory struct
```bash
regular-delete
├── conf
│   └── .clear.conf
├── scripts
│   └── clear.sh
└── service
    └── regular-delete.service
```

### conf 
adjust config: /usr/local/bin/conf/clear.conf
```bash
### -------  share param  ------- ###
# The trigger condition for the disk
export DISKCMD="df -TH | grep ext4"

# sleep time
SLEEP=120

# Threshold Unit GB
THRESHOLD="50"

# Regular cleaning of file types can not | end
Ftype=".bag$|.bag.*$"

# A folder that needs to be cleaned regularly
CLEAR_PATH_LIST=(
    "/home/*/Documents/well_driver"
    "/data/wellpilot"
) 

# mode  close/open
SAFETY=close

### ------- The following parameters take effect when the mode is close ------- ###
# Retain time, logic is based on the current time forward 24h, the rest of the files are deleted
RETAIN_DAY=1
CLOSE_LAYER=1

### ------- The following parameters take effect when the mode is open ------- ###
# + out of range / - in range
CONDITION="+"
# Days
DAY="3"
# Range of matches
OPEN_LAYER=1
```

## install 
```bash
bash deploy.sh --install 
```
## adjust config
```bash
bash deploy.sh --config
```
## remove 
```bash
bash deploy.sh --remove
```
