#!/bin/bash
set -e

printf "UPS server ip: "
read serverip

printf "Upsmon user (default 'upsmon'): "
read upsmonuser

printf "Upsmon password (default 'secret'): "
read upsmonpw

printf "UPS client ip: "
read clientip

printf "Time in seconds before client enters shutdown: "
read shutdowntime

printf "\nInstalling apt nut-client package...\n"
ssh root@${clientip} "apt update && apt install nut-client=2.7.4-13 -y"

printf "\nCopying config files to ups client...\n"
scp -r ./nut-client root@${clientip}:/root/nut-client

printf "\nSetting the correct values and permissions...\n"
set-config(){
    local shutdowntime=${1}
    local upsmonuser=${2}
    local upsmonpw=${3}
    local serverip=${4}

    cp -r /root/nut-client/* /etc/nut/

    sed -i "s/900/${shutdowntime}/g" /etc/nut/upssched.conf
    sed -i "s/mymonuser/${upsmonuser}/g" /etc/nut/upsmon.conf
    sed -i "s/mysecretpw/${upsmonpw}/g" /etc/nut/upsmon.conf
    sed -i "s/x.x.x.x/${serverip}/g" /etc/nut/upsmon.conf

    chown root:root /etc/nut/*
    chmod 640 /etc/nut/*
    chmod 755 /etc/nut/upssched-cmd

    rm -rf /root/nut-client
}
typeset -f set-config | ssh root@${clientip} "$(cat); set-config ${shutdowntime} ${upsmonuser} ${upsmonpw} ${serverip}"

printf "\n(Re)starting nut-client...\n"
start(){
    systemctl restart nut-client
    status=$(systemctl is-active nut-client)
    printf "\n--------------------------------------------------------------------\n"
    if [[ ${status} == "active" ]];
    then 
        echo "Successfully installed!"
    else
        echo "FAILED! Something went wrong during the installation."
    fi
    echo "--------------------------------------------------------------------"
}
typeset -f start | ssh root@${clientip} "$(cat); start"