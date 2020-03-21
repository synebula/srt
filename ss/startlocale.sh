#!/bin/bash
IP=$1
if [ "$IP" != "" ]; then
cat > config.json << EOF
{
    "server":"$IP",
    "server_port":8080,
    "local_address": "127.0.0.1",
    "local_port":1080,
    "password":"uay9KyBHpbCOdGm5",
    "timeout":300,
    "method":"aes-256-cfb",
    "fast_open": false
}
EOF
fi

ss-local -c config.json --plugin obfs-local --plugin-opts "obfs=http;obfs-host=laverna.cc"
