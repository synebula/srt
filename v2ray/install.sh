#!/bin/bash

if [ ！-n "$1" ]; then  
  echo "please tell me the domain name"  
  exit 0
fi

#1. 准备软件包
echo 'ready software'
UUID=`(cat /proc/sys/kernel/random/uuid)`
mkdir -p $HOME/{app/html,pkg,crt,doc}
sudo apt install nginx -y
curl -L -s https://install.direct/go.sh | sudo bash
curl https://get.acme.sh | bash

#2. 准备环境
echo 'ready envirment'
# LE_WORKING_DIR在https://get.acme.sh中定义
. $LE_WORKING_DIR/acme.sh.env
cat > $HOME/app/html/index.html << EFO
<html>
	<head><title>Hello world</title></head>
	<body><h1>Hello, the beautiful world!</h1></body>
</html>
EFO

sudo cat > $HOME/doc/v2ray.conf << EFO
server {
  listen 80; 
  server_name $1;
  root $HOME/app/html;
}
EFO
sudo mv $HOME/doc/v2ray.conf /etc/nginx/conf.d/

sudo systemctl restart nginx
$LE_WORKING_DIR/acme.sh --issue -d $1 -w $HOME/app/html

# 3.准备配置
echo 'ready configuation'
cat > $HOME/doc/v2ray-tls.conf << EFO
server {
    listen  443 ssl;
    server_name $1;
    ssl on;
    ssl_certificate       $HOME/crt/fullchain.pem;
    ssl_certificate_key   $HOME/crt/v2ray.key;
    ssl_protocols         TLSv1 TLSv1.1 TLSv1.2;
    ssl_ciphers           HIGH:!aNULL:!MD5;
    root $HOME/app/html;
    location /ray { # 与 V2Ray 配置中的 path 保持一致
    proxy_redirect off;
        proxy_pass http://127.0.0.1:10000;#假设WebSocket监听在环回地址的10000端口上
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$http_host;

        # Show realip in v2ray access.log
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
}
EFO
sudo mv $HOME/doc/v2ray-tls.conf /etc/nginx/conf.d/

sudo cat > $HOME/doc/config.json  << EFO
{
  "inbounds": [
    {
      "port": 10000,
      "listen":"127.0.0.1",//只监听 127.0.0.1，避免除本机外的机器探测到开放了 10000 端口
      "protocol": "vmess",
      "settings": {
        "clients": [
          {
            "id": "$UUID",
            "alterId": 62
          }
        ]
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": {
        "path": "/ray"
        }
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom",
      "settings": {}
    }
  ]
}
EFO
sudo mv $HOME/doc/config.json /etc/v2ray/

# 4.启动服务
echo 'start service'
# LE_WORKING_DIR在https://get.acme.sh中定义
$LE_WORKING_DIR/acme.sh --install-cert -d $1 \
--cert-file      $HOME/crt/v2ray.crt  \
--key-file       $HOME/crt/v2ray.key  \
--fullchain-file $HOME/crt/fullchain.pem \
--reloadcmd     "sudo systemctl restart nginx"
sudo systemctl restart v2ray

echo "finish, token is $UUID"
