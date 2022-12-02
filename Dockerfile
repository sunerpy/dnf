FROM centos:centos7
LABEL version="1.0" MAINTAINER="sunerpy"
# 定义默认环境变量
ENV AUTO_PUBLIC_IP=false \
    PRELOAD_LD=true \
    PUBLIC_IP=127.0.0.1 \
    GM_ACCOUNT=gm_user \
    GM_PASSWORD=gm_pass \
    DNF_DB_ROOT_PASSWORD=88888888 \
    DNF_DB_GAME_PASSWORD=uu5!^%jg \
    TZ=Asia/Shanghai \
    LANG=en_US.utf8
COPY . /home/template
RUN mv /home/template/TeaEncrypt / && chmod a+x /TeaEncrypt && \
    echo 'PATH=$PATH:/opt/lampp/bin' >> /root/.bashrc && source /root/.bashrc && \
    tar xf /home/template/DnfServer.tar.xz -C /home/template && \
    mv /home/template/docker-entrypoint.sh / && \
    tar xf /home/template/GeoIP-1.4.8.tgz -C /home/ && \
    mv /home/template/lampp /opt/ && \
    mv /home/template/lib/* /lib/ && \
    LD_VER=$(ls /lib/ld-*.so|sed -r 's/([^[:digit:]]+)([[:digit:].]+)(\.[^[:digit:]]+)/\2/') && \
    sed -i "s|LD_ASSUME_KERNEL=.*$|LD_ASSUME_KERNEL=${LD_VER}|" /opt/lampp/lampp && \
    mv /home/template/libhook.so /lib/ && \
    rm -rf /etc/yum.repos.d/CentOS-[^B]*.repo && \
    sed -i "s|enabled=1|enabled=0|g" /etc/yum/pluginconf.d/fastestmirror.conf && \
    sed -i '{s|^mirrorlist=|#mirrorlist=|g};{s|^#baseurl=http://mirror.centos.org/centos|baseurl=https://mirrors.ustc.edu.cn/centos|g}' \
    /etc/yum.repos.d/CentOS-Base.repo && \
    yum clean all && yum makecache && \
    yum install -y gcc gcc-c++ make zlib-devel psmisc openssl openssl-devel libssl.so.6 net-tools && \
    ln -sf /usr/lib64/libssl.so.10 /usr/lib64/libssl.so.6 && ln -sf /usr/lib64/libcrypto.so.10 /usr/lib64/libcrypto.so.6 && \
    cd /home/GeoIP-1.4.8/ && chmod 777 configure && ./configure && make && make install && \
    rm -rf /home/GeoIP-1.4.8/ && \
    yum clean all && rm -rf /var/cache/yum/* /home/template/DnfServer.tar.xz /home/template/GeoIP-1.4.8.tgz
WORKDIR /root
CMD ["/bin/bash","/docker-entrypoint.sh"]
#默认等级补丁为95级，如需更换等级补丁直接替换 df_game_r文件即可