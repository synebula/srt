#!/bin/bash
sudo apt-get update;
sudo apt-get install -y --no-install-recommends git build-essential autoconf libtool libev-dev libpcre3-dev xmlto automake asciidoc libc-ares-dev libmbedtls-dev gettext libsodium-dev libssl-dev 

### obfs
git clone https://github.com/shadowsocks/simple-obfs.git
pushd simple-obfs
git submodule update --init --recursive
./autogen.sh
./configure && make
sudo make install
popd

### ss
# Installation of Libsodium
export LIBSODIUM_VER=1.0.13
wget https://download.libsodium.org/libsodium/releases/libsodium-$LIBSODIUM_VER.tar.gz
tar xvf libsodium-$LIBSODIUM_VER.tar.gz
pushd libsodium-$LIBSODIUM_VER
./configure --prefix=/usr && make
sudo make install
popd
sudo ldconfig

# Installation of MbedTLS
export MBEDTLS_VER=2.6.0
wget https://tls.mbed.org/download/mbedtls-$MBEDTLS_VER-gpl.tgz
tar xvf mbedtls-$MBEDTLS_VER-gpl.tgz
pushd mbedtls-$MBEDTLS_VER
make SHARED=1 CFLAGS=-fPIC
sudo make DESTDIR=/usr install
popd
sudo ldconfig

# Start building
git clone https://github.com/shadowsocks/shadowsocks-libev.git
pushd shadowsocks-libev
git submodule update --init --recursive
./autogen.sh && ./configure --with-sodium-include=/usr/include/ --with-sodium-lib=/usr/lib/ --with-mbedtls-include=/usr/include/ --with-mbedtls-lib=/usr/lib/&& make
sudo make install
popd

