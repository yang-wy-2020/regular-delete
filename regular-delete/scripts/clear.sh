#!/bin/bash

readonly base="/usr/local/bin/"

if [ ! -f ${base}/clear_conf/clear.conf ];then
    echo "conf file not exist";exit -1
fi 

source ${base}/clear_conf/clear.conf || true

AMD_TYPE="x86_64"
ARM_TYPE="aarch64"
DELETE_NUMBER="10"

function Clear() {
    if [ ! -s ${1} ];then 
        echo "empty";
    else
            echo "==========Del List=========="
            echo "$(cat ${1})"
            echo "============================"
        for file in $(cat ${1}); do
            sudo rm  ${file} &> /dev/null
        done
    fi 
}

function CheckTmpFile() {
    if [ ! -f ${1} ]; then
        echo "$1 is empty, path -> $2"
    else
        Clear $1
    fi
}

function SafetyHandle() {
    local ts=$(date +%s)
    local tmp_file="/tmp/tmp_SafetyHandle.log"
    touch ${tmp_file}
    find ${1} -maxdepth ${OPEN_LAYER} -type f -mtime ${CONDITION}${DAY} | egrep "${Ftype}" > ${tmp_file} 
    sort -n ${tmp_file} > /tmp/${2}-${ts}.txt      # sort rules: change time
    CheckTmpFile /tmp/${2}-${ts}.txt ${1}
}

function NotSafetyHandle() {
    local ts=$(date +%s)
    local tmp_file="/tmp/tmp_NotSafetyHandle.log"
    touch ${tmp_file}
    local cutoff=$(date -d "${RETAIN_DAY} day ago" '+%s') 
    find ${1} -maxdepth ${CLOSE_LAYER} -type f ! -newermt @$cutoff | egrep "${Ftype}"  > ${tmp_file} 
    CheckTmpFile ${tmp_file}
}

function SafetyDiskSpaceRelease() {

    if [[ $1 == "close" ]];then
        handle=NotSafetyHandle
    else
        handle=SafetyHandle
    fi 

    for sub_path in ${CLEAR_PATH_LIST[@]}; do
        if [ -d ${sub_path} ];then
            $handle ${sub_path} $(arch)
        else
            echo "${sub_path} is not exist"
        fi 
    done
}

while true;do
    sleep ${SLEEP}
    usable=$(echo $(eval $DISKCMD) | tail -n 1 | awk '{print $5}' | cut -f 1 -d 'G')
    result=$(echo "${usable} < ${THRESHOLD}" | bc)
    case "${SAFETY}" in 
    "close")
        if [ "${result}" -eq 1 ]; then
            echo "Avail ${usable}, will clean"
            while true; do
                sleep 1; SafetyDiskSpaceRelease "close"
                usable=$(echo $(eval $DISKCMD) | tail -n 1 | awk '{print $5}' | cut -f 1 -d 'G')
                result=$(echo "${usable} < ${THRESHOLD}" | bc)
                if [ "${result}" -ne 1 ]; then
                    break  
                else
                    sleep ${SLEEP}
                fi
            done 
        else
            echo ${usable}
        fi
        ;;
    "open")
        if [ "${result}" -eq 1 ]; then
            echo "Avail ${usable}, will clean"
            SafetyDiskSpaceRelease
        else
            echo ${usable}
        fi
        ;;
    *)
        echo "safety mode error"
        ;;
    esac  
done 
