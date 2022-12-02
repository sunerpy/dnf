#!/bin/bash
export LANG=en_US.utf-8
##########################################################################
#    @File    :   init.sh
#    @Time    :   2022/12/01 16:57:27
#    @Author  :   sunerpy
#    @Version :   1.0
#    @Contact :   sunerpy<nkuzhangshn@gmail.com>
#    @Desc    :   None

set -o nounset

LOGFILE=/tmp/init_$(date +%Y%m%d).log
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

#清理mysql
initMysql() {
    # rm -rf /opt/lampp/var/mysql
    tar xf /home/template/root/MySQL.tar.gz -C /
    /opt/lampp/lampp startmysql
}
cd /home/template || logger error "目录异常退出"
# 判断数据库是否初始化过
if [[ ! -d "/opt/lampp/var/mysql/d_taiwan" ]]; then
    initMysql
else
    logger debug "mysql have already inited, do nothing!"
fi

# 判断Script.pvf文件是否初始化过
if [[ ! -f "/data/Script.pvf" ]]; then
    tar xf /home/template/Script.tar.xz -C /data/
    rm -f /home/template/Script.tar.xz
    # 拷贝版本文件到持久化目录
    logger debug "init Script.pvf success"
else
    echo "Script.pvf have already inited, do nothing!"
fi

# 判断df_game_r文件是否初始化过
if [ ! -f "/data/df_game_r" ]; then
    # 拷贝版本文件到持久化目录
    cp /home/template/neople/game/df_game_r /data/
    echo "init df_game_r success"
else
    echo "df_game_r have already inited, do nothing!"
fi

# 判断privatekey.pem文件是否初始化过
if [ ! -f "/data/privatekey.pem" ]; then
    # 拷贝版本文件到持久化目录
    cp /home/template/privatekey.pem /data/
    echo "init privatekey.pem success"
else
    echo "privatekey.pem have already inited, do nothing!"
fi

# 判断publickey.pem文件是否初始化过
if [ ! -f "/data/publickey.pem" ]; then
    # 拷贝版本文件到持久化目录
    cp /home/template/publickey.pem /data/
    echo "init publickey.pem success"
else
    echo "publickey.pem have already inited, do nothing!"
fi

if [[ $(ps -ef | grep mysql -c) -ge 1 ]]; then
    /opt/lampp/lampp stopmysql
fi
# rm -rf /home/template
