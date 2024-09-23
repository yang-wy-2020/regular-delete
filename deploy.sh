#!/bin/bash

Choose=$1
ServiceName="regular-delete.service"
InstallPath="/usr/loca/bin/"

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
    if [ ! -f ${InstallPath}/conf/clear.conf ] ;then
        sudo cp -r ./regular-delete/conf  ${InstallPath}/clear_conf
        sudo cp -r  ${InstallPath}/conf/.clear.conf  ${InstallPath}/clear_conf/clear.conf 
    fi 
    systemctl daemon-reload
    if [[ $(systemctl is-active ${ServiceName}) != "active" ]];then
        cp ./regular-delete/service/${ServiceName} /lib/systemd/system/
        systemctl enable ${ServiceName}
        systemctl restart ${ServiceName}
    else
        systemctl restart ${ServiceName}
    fi
}

remove()
{
   systemctl disable ${ServiceName}
   rm -rf ${InstallPath}/clear_conf 
}

config()
{
    sudo vim ${InstallPath}/clear.conf
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