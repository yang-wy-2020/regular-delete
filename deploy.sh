#!/bin/bash

Choose=$1
ServiceName="regular-delete.service"
InstallPath="/usr/local/bin/"

Usage()
{
    echo "Options: bash $(basename $0) args"
    echo -e "\t --install"
    echo -e "\t\t deploy regular delete"
    echo -e "\t --remove"
    echo -e "\t\t remove regular delete"
    echo -e "\t --config"
    echo -e "\t\t adjust config file"
}

install()
{
    if [ ! -f ${InstallPath}/clear_conf/clear.conf ] ;then
        sudo cp -r ./regular-delete/conf  ${InstallPath}/clear_conf
        sudo cp -r  $(pwd)/regular-delete/conf/.clear.conf  ${InstallPath}/clear_conf/clear.conf 
    fi 
    systemctl daemon-reload
    if [[ $(systemctl is-active ${ServiceName}) != "active" ]];then
        sudo cp ./regular-delete/service/${ServiceName} /lib/systemd/system/
        systemctl enable ${ServiceName}
        systemctl restart ${ServiceName}
    else
        systemctl restart ${ServiceName}
    fi
}

remove()
{
   systemctl disable ${ServiceName}
   sudo rm -rf ${InstallPath}/clear_conf 
}

config()
{
    if [ ! -f "${InstallPath}/clear_conf/clear.conf" ];then 
        echo "please run --install" ; exit -1
    fi 
    sudo vim ${InstallPath}/clear_conf/clear.conf
}

case ${Choose} in
"--install"|"-i")
    install ;;
"--remove"|"-r")
    remove ;;
"--config"|"-c")
    config ;;
*)
    Usage ;;
esac