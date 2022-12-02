# 地下城与勇士容器版本


## 说明

本项目使用官方Centos: 7.9为基础镜像，使用XAMPP以及dnf台服服务端代码完成服务端部署

项目源自于[1995chen/dnf (github.com)](https://github.com/1995chen/dnf) ，修改的地方在于服务端未使用网关工具，可使用通用登录器直接登录，可自行替换PVF和等级补丁，可根据本项目的Dockerfile自行编译镜像

感谢 xyz1001大佬提供`libhook.so`优化CPU占用 [源码](https://godbolt.org/z/EKsYGh5dv)

## 部署流程

### Centos安装Docker

centos 7版本以上

```shell
yum config-manager \
    --add-repo \
    https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
yum -y install docker
```

启动docker并设置开机自启

```shell
systemctl enable docker --now
```

关闭防火墙和selinux(最新版本的如果使用的为nftables，则不含有firewalld)

```shell
systemctl disable firewalld --now
sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
```

## 启动服务端

```shell
# 创建一个目录,这里以/dnfpv为例,后续会将该目录下的mysql以及data目录挂载到容器内部
mkdir -p /dnfpv
# 初始化数据库以及基础数据文件(该过程耗时较长,可能会超过10分钟请耐心等待)
# 该初始化容器是个一次性任务,跑完会在data, mysql目录下创建初始化文件，程序运行完成后自动退出,不会留下任务容器残留
# 如果要重新初始化数据,则需要删除mysql, log, data目录重新运行该初始化命令，注意:如果目录没有清空是不会执行任何操作的
docker run --rm -v /dnfpv/log:/home/neople/game/log -v /dnfpv/mysql:/var/lib/mysql -v /dnfpv/data:/data dnf:centos7 /bin/bash /home/template/init.sh

# 启动服务
# PUBLIC_IP为公网IP地址，如果在局域网部署则用局域网IP地址，按实际需要替换
docker run -d -e PUBLIC_IP=x.x.x.x -v /dnfpv/log:/home/neople/game/log -v /dnfpv/mysql:/var/lib/mysql -v /dnfpv/data:/data -p 3000:3306/tcp -p 7600:7600/tcp -p 881:881/tcp -p 20303:20303/tcp -p 20303:20303/udp -p 20403:20403/tcp -p 20403:20403/udp -p 40403:40403/tcp -p 40403:40403/udp -p 7000:7000/tcp -p 7000:7000/udp -p 7001:7001/tcp -p 7001:7001/udp -p 7200:7200/tcp -p 7200:7200/udp -p 10011:10011/tcp -p 31100:31100/tcp -p 30303:30303/tcp -p 30303:30303/udp -p 30403:30403/tcp -p 30403:30403/udp -p 10052:10052/tcp -p 20011:20011/tcp -p 20203:20203/tcp -p 20203:20203/udp -p 30703:30703/udp -p 11011:11011/udp -p 2311-2313:2311-2313/udp -p 30503:30503/udp -p 11052:11052/udp --cpus=1 --shm-size=8g --name=dnf dnf:centos7
```

## 如何确认已经成功启动

1.查看日志 log
```
├── siroco11
│ ├── Log20211203-09.history
│ ├── Log20211203.cri
│ ├── Log20211203.debug
│ ├── Log20211203.error
│ ├── Log20211203.init
│ ├── Log20211203.log
│ ├── Log20211203.money
│ └── Log20211203.snap
└── siroco52
├── Log20211203-09.history
├── Log20211203.cri
├── Log20211203.debug
├── Log20211203.error
├── Log20211203.init
├── Log20211203.log
├── Log20211203.money
└── Log20211203.snap
```
查看Logxxxx.init文件,五国的初始化日志都在这里
成功出现五国后,日志文件大概如下,五国初始化时间大概1分钟左右,请耐心等待
```
[root@centos-02 siroco11]# tail -f Log20211203.init
[09:40:23] - RestrictBegin : 1
[09:40:23] - DropRate : 0
[09:40:23] Security Restrict End
[09:40:23] GeoIP Allow Country Code : CN
[09:40:23] GeoIP Allow Country Code : HK
[09:40:23] GeoIP Allow Country Code : KR
[09:40:23] GeoIP Allow Country Code : MO
[09:40:23] GeoIP Allow Country Code : TW
[09:40:32] [!] Connect To Guild Server ...
[09:40:32] [!] Connect To Monitor Server ...
```
2.查看进程
在确保日志都正常的情况下,需要查看进程进一步确定程序正常启动
```
[root@centos-02 siroco11]# ps -ef |grep df_game
root 16500 16039 9 20:39 ? 00:01:20 ./df_game_r siroco11 start
root 16502 16039 9 20:39 ? 00:01:22 ./df_game_r siroco52 start
root 22514 13398 0 20:53 pts/0 00:00:00 grep --color=auto df_game
```
如上结果df_game_r进程是存在的,代表成功.如果不成功可以重启服务

## 重启服务

该服务占有内存较大，极有可能被系统杀死,当进程被杀死时则需要重启服务
重启服务命令

```shell
docker restart dnf
```

## 默认信息

数据库用户：game

数据库密码： 123456

## 声明

```
虽然支持外网，但是千万别拿来开服。只能拿来学习使用!!!
虽然支持外网，但是千万别拿来开服。只能拿来学习使用!!!
虽然支持外网，但是千万别拿来开服。只能拿来学习使用!!!
```
