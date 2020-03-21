#!/bin/bash
### config
IP=''
PASSWD = "this15p@55wd"
get_ip(){
    IP=$(ip a | grep inet | grep -v inet6 | grep -v 127 | sed 's/^[ \t]*//g' | cut -d ' ' -f2)
    IP=${IP%/*}
}
get_ip

cat > config.json << EOF
{
    "server":"$IP",
    "server_port":8080,
    "local_address": "127.0.0.1",
    "local_port":1080,
    "password":"$PASSWD",
    "timeout":300,
    "method":"aes-256-cfb",
    "fast_open": false
}
EOF


### start 
# 需要在本机8090端口运行html应用, 浏览器访问可代理到该端口应用
#obfs-server -s ${IP} -p 8080 --obfs http -r 127.0.0.1:8388 --failover 127.0.0.1:8090 &
#ss-server -c config.json -s 127.0.0.1 -p 8388
ss-server -c config.json --plugin obfs-server --plugin-opts "obfs=http;failover=127.0.0.1:8090"