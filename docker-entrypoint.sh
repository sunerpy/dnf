#!/bin/bash
export LANG=en_US.utf-8
##########################################################################
#    @File    :   docker-entrypoint.sh
#    @Time    :   2022/11/25 20:25:13
#    @Author  :   sunerpy
#    @Version :   1.0
#    @Contact :   sunerpy<nkuzhangshn@gmail.com>
#    @Desc    :   None

set -o nounset
# set -o errexit

LOGFILE=/tmp/dnf_$(date +%Y%m%d).log
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

# 删除无用文件
# rm -rf /home/template/neople-tmp
# rm -rf /home/template/root-tmp
# mv /home/template/neople /home/
# 清理root下文件
rm -rf /root/*
mv /home/template/root/* /root/
# 复制待使用文件
# cp -r /home/template/neople /home/template/neople-tmp
# cp -r /home/template/root /home/template/root-tmp

# 获取公网ip
# if $AUTO_PUBLIC_IP;
# then
#   PUBLIC_IP=`curl -s http://pv.sohu.com/cityjson?ie=utf-8|awk -F\" '{print $4}'`
#   echo "public ip: $PUBLIC_IP"
#   sleep 5
# fi

# chmod +x /TeaEncrypt
# DNF_DB_GAME_PASSWORD=${DNF_DB_GAME_PASSWORD:0:8}
# DEC_GAME_PWD=`/TeaEncrypt $DNF_DB_GAME_PASSWORD`
# echo "game password: $DNF_DB_GAME_PASSWORD"
# echo "game pwd key: $DEC_GAME_PWD"

# # 替换环境变量
# find /home/neople -type f -name "*.cfg" -print0 | xargs -0 sed -i "s/GAME_PASSWORD/$DNF_DB_GAME_PASSWORD/g"
# find /home/neople -type f -name "*.cfg" -print0 | xargs -0 sed -i "s/DEC_GAME_PWD/$DEC_GAME_PWD/g"
# find /home/neople -type f -name "*.cfg" -print0 | xargs -0 sed -i "s/PUBLIC_IP/$PUBLIC_IP/g"
# find /home/neople -type f -name "*.tbl" -print0 | xargs -0 sed -i "s/PUBLIC_IP/$PUBLIC_IP/g"
# 将结果文件拷贝到对应目录[这里是为了保住日志文件目录,将日志文件挂载到宿主机外,因此采用覆盖而不是mv]
# cp -rf /home/template/neople-tmp/* /home/neople
cp -rf /home/template/neople/* /home/neople
rm -rf /home/template/neople
find /home/neople/ -type f -name "*.cfg" -print0 | xargs -0 sed -i "s/Public IP/ $PUBLIC_IP/g"
# 复制版本文件
cp /data/Script.pvf /home/neople/game/Script.pvf
chmod 777 /home/neople/game/Script.pvf
cp /data/df_game_r /home/neople/game/df_game_r
chmod 777 /home/neople/game/df_game_r
cp /data/publickey.pem /home/neople/game/

# mv /home/template/root-tmp/* /root/
# rm -rf /home/template/root-tmp
# chmod 777 /root/*
# # 拷贝证书key
# cp /data/privatekey.pem /root/
# # 构建配置文件软链[不能使用硬链接, 硬链接不可跨设备]
# ln -s /data/Config.ini /root/Config.ini
# # 替换Config.ini中的GM用户名、密码、连接KEY、登录器版本[这里操作的对象是一个软链接不需要指定-type]
# sed -i --follow-symlinks "s/GAME_PASSWORD/$DNF_DB_GAME_PASSWORD/g" `find /root -name "*.ini"`
# sed -i --follow-symlinks "s/GM_ACCOUNT/$GM_ACCOUNT/g" `find /root -name "*.ini"`
# sed -i --follow-symlinks "s/GM_PASSWORD/$GM_PASSWORD/g" `find /root -name "*.ini"`
# sed -i --follow-symlinks "s/GM_CONNECT_KEY/$GM_CONNECT_KEY/g" `find /root -name "*.ini"`
# sed -i --follow-symlinks "s/GM_LANDER_VERSION/$GM_LANDER_VERSION/g" `find /root -name "*.ini"`
DNF_DB_ROOT_PASSWORD="Testing#123"
DNF_DB_GAME_PASSWORD="123456"
DEC_GAME_PWD="123456"

sed -i '/^\[mysqld\]/askip-grant-tables' /opt/lampp/etc/my.cnf
/opt/lampp/lampp startmysql
mysql -uroot << EOF
create user 'root'@'localhost' identified by '$DNF_DB_ROOT_PASSWORD';
EOF

mysql -uroot << EOF
flush privileges;
create user 'root'@'localhost' identified by '$DNF_DB_ROOT_PASSWORD';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' WITH GRANT OPTION;
flush privileges;
EOF

# 重建root, game用户,并限制game只能容器内服务访问
# grant all privileges on *.* to 'game'@'127.0.0.1' identified by '$DNF_DB_GAME_PASSWORD';
#service mysql start --skip-grant-tables
# delete from mysql.user;
# service mariadb start --skip-grant-tables
mysql -u root -p$DNF_DB_ROOT_PASSWORD <<EOF
flush privileges;
grant all privileges on *.* to 'root'@'%' identified by '$DNF_DB_ROOT_PASSWORD';
flush privileges;
select user,host,password from mysql.user;
EOF
sed -i 's/skip-grant-tables.*/#&/' /opt/lampp/etc/my.cnf
# 关闭服务
#127.0.0.1 uu5!^%jg
/opt/lampp/lampp stopmysql
/opt/lampp/lampp startmysql

# 修改数据库IP和端口 & 刷新game账户权限只允许本地登录
# mysql -u root -p$DNF_DB_ROOT_PASSWORD -P 3306 -h 127.0.0.1 <<EOF
# update d_taiwan.db_connect set db_ip="127.0.0.1", db_port="3306", db_passwd="$DEC_GAME_PWD";
# select * from d_taiwan.db_connect;
# EOF
rm -rf /home/template
cd /root || logger error "Change dir failed."
# 启动服务
./run
