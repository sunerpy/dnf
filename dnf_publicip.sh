#!/bin/bash
export LANG=en_US.utf-8
##########################################################################
#    @File    :   publicip.sh
#    @Time    :   2022/11/20 23:58:39
#    @Author  :   sunerpy
#    @Version :   1.0
#    @Contact :   sunerpy<nkuzhangshn@gmail.com>
#    @Desc    :   None

# set -o nounset
# set -o errexit

LOGFILE=/tmp/acrs_$(date +%Y%m%d).log
date >"${LOGFILE}"

logger() {
    TIMESTAMP=[$(date +'%Y-%m-%d %H:%M:%S')]
    case "$1" in
    debug)
        echo -e "$TIMESTAMP \033[36m[DEBUG]\033[0m $2" | tee -a "${LOGFILE}"
        ;;
    info)
        echo -e "$TIMESTAMP \033[32m[INFO]\033[0m  $2" | tee -a "${LOGFILE}"
        ;;
    warn)
        echo -e "$TIMESTAMP \033[33m[WARN]\033[0m  $2" | tee -a "${LOGFILE}"
        ;;
    error)
        echo -e "$TIMESTAMP \033[31m[ERROR]\033[0m $2" | tee -a "${LOGFILE}"
        exit 1
        ;;
    *)
        echo -e "$TIMESTAMP \033[31mParameters wrong\033[0m $2" | tee -a "${LOGFILE}"
        exit 1
        ;;
    esac
}

suCmd() {
    osuser=$1
    cmd=$2
    su - "${osuser}" -c "${cmd}"
}

linuxDistribution() {
    osDistrit=$(awk '{if(toupper($1) == "CENTOS") {print toupper($1)} else {print toupper($1) toupper($2)}}' /etc/system-release)
    if [[ "${osDistrit}" != "CENTOS" && "${osDistrit}" != "REDHAT" ]]; then
        logger error "Unsupported OS."
    fi
}

restartDnf(){
    . /root/stop &>/dev/null
    sleep 3
    . /root/stop &>/dev/null
    sleep 3
    . /root/run &
    sleep 120
}

gameHomeDir=/home/neople
while true
do
    preCfgIp=$(awk -F '=' '/^ip /{print $2 }' $(find ${gameHomeDir} -name "siroco11.cfg"))
    curl -s https://ddns.oray.com/checkip &> /dev/null
    ipFlag=$?
    if [[ $(du -sm "${LOGFILE}" |awk '{print $1}') -ge 10 ]];then
        date > "${LOGFILE}"
    fi
    if [[ ${ipFlag} -ne 0 ]];then
        logger "IP获取失败,请检查"
        continue
    else
        nowIp=$(curl -s https://ddns.oray.com/checkip | awk '{print $NF}')
        ipcalc -c "${nowIp}" &> /dev/null
        if [[ $? -ne 0 ]];then
            continue
        fi
        if [[ "${nowIp}" == "${preCfgIp}" ]];then
            logger debug "IP未发生变化,继续监测..."
            sleep 30
            continue
        else
            logger debug "IP发生变化,开始变更IP信息..."
            find ${gameHomeDir} -type f -name "*.cfg" -print0 | xargs -0 -I "R" sed -i "s/${preCfgIp}/${nowIp}/g" "R"
            logger debug "IP变更为${nowIp},重新启动dnf"
            cd /root/ || logger error "异常退出"
            . /root/stop &>/dev/null
            sleep 1
            . /root/stop &>/dev/null
            sleep 1
            . /root/run &
            sleep 360
            dnfStatusNum=$(awk '/GeoIP Allow Country/{a++}END{print a}' ${gameHomeDir}/game/log/siroco11/Log*.init )
            if [[ ${dnfStatusNum} -ge 4 ]];then
                logger info "dnf重新启动成功..."
            else
                logger error "dnf重新启动失败...请查看日志处理"
            fi
            continue
        fi
    fi
done