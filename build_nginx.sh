#!/usr/bin/env bash
# Refer to:
#   1. https://gist.github.com/Belphemur/3c022598919e6a1788fc
#   2. https://gist.github.com/MattWilcox/402e2e8aa2e1c132ee24
#   3. https://github.com/MatthewVance/nginx-build/blob/master/build-nginx.sh

# Make script exit if a simple command fails and
set -e

# names of latest versions of each package
export NGINX_VERSION=1.15.5
export VERSION_PCRE=pcre-8.42
export VERSION_ZLIB=zlib-1.2.11
export VERSION_OPENSSL=openssl-1.0.2p
export VERSION_NGINX=nginx-$NGINX_VERSION
# URLs to the source directories
export SOURCE_PCRE=https://ftp.pcre.org/pub/pcre/
export SOURCE_ZLIB=https://zlib.net/
export SOURCE_OPENSSL=https://www.openssl.org/source/
export SOURCE_NGINX=https://nginx.org/download/
 
# clean out any files from previous runs of this script
rm -rf build
mkdir build

# proc for building faster
NB_PROC=$(grep -c ^processor /proc/cpuinfo)
 
# ensure that we have the required software to compile our own nginx
sudo apt-get -y install wget build-essential
 
# grab the source files
echo "Download sources"
wget -P ./build $SOURCE_NGINX$VERSION_NGINX.tar.gz
wget -P ./build $SOURCE_PCRE$VERSION_PCRE.tar.gz
wget -P ./build $SOURCE_ZLIB$VERSION_ZLIB.tar.gz
wget -P ./build $SOURCE_OPENSSL$VERSION_OPENSSL.tar.gz
 
# expand the source files
echo "Extract Packages"
cd build
tar xzf $VERSION_NGINX.tar.gz
tar xzf $VERSION_OPENSSL.tar.gz
tar xzf $VERSION_PCRE.tar.gz
tar xzf $VERSION_ZLIB.tar.gz
 
# build nginx, with various modules included/excluded
echo "Configure & Build Nginx"
cd ./$VERSION_NGINX
./configure --prefix=/usr/local/nginx \
--conf-path=/etc/nginx/nginx.conf \
--pid-path=/run/nginx.pid \
--error-log-path=/var/log/nginx/error.log \
--http-log-path=/var/log/nginx/access.log \
--with-pcre=../$VERSION_PCRE \
--with-pcre-jit \
--with-openssl=../$VERSION_OPENSSL \
--with-zlib=../$VERSION_ZLIB \
--with-http_ssl_module \
--with-http_realip_module \
--with-http_v2_module \
--with-http_stub_status_module \
--with-stream \
--with-stream_ssl_module \
--with-stream_realip_module
 
make -j $NB_PROC
 
echo "Build done.";
echo "Enter `sudo make install` to install nginx.";
