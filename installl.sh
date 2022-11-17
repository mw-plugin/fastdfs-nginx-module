#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin


mkdir -p /www/server/source
cd /www/server/source

git clone https://github.com/happyfish100/fastdfs-nginx-module



VERSION=1.21.4.1

install_tmp=/www/server/mdserver-web/tmp/mw_install.pl
openrestyDir=/www/server/source/openresty


mkdir -p ${openrestyDir}
echo '正在安装脚本文件...' > $install_tmp


# ----- cpu start ------
if [ -z "${cpuCore}" ]; then
	cpuCore="1"
fi

if [ -f /proc/cpuinfo ];then
	cpuCore=`cat /proc/cpuinfo | grep "processor" | wc -l`
fi

MEM_INFO=$(free -m|grep Mem|awk '{printf("%.f",($2)/1024)}')
if [ "${cpuCore}" != "1" ] && [ "${MEM_INFO}" != "0" ];then
    if [ "${cpuCore}" -gt "${MEM_INFO}" ];then
        cpuCore="${MEM_INFO}"
    fi
else
    cpuCore="1"
fi

if [ "$cpuCore" -gt "2" ];then
	cpuCore=`echo "$cpuCore" | awk '{printf("%.f",($1)*0.8)}'`
else
	cpuCore="1"
fi
# ----- cpu end ------


rm -rf ${openrestyDir}/openresty-${VERSION}
rm -rf ${openrestyDir}/openresty-${VERSION}.tar.gz

if [ ! -f ${openrestyDir}/openresty-${VERSION}.tar.gz ];then
	wget -O ${openrestyDir}/openresty-${VERSION}.tar.gz https://openresty.org/download/openresty-${VERSION}.tar.gz
fi


cd ${openrestyDir} && tar -zxvf openresty-${VERSION}.tar.gz

cd ${openrestyDir}/openresty-${VERSION} && ./configure \
--with-cc-opt=-O2 \
--prefix=/www/server/openresty \
--with-ipv6 \
--with-stream \
--with-http_v2_module \
--with-http_ssl_module  \
--with-http_slice_module \
--with-http_stub_status_module \
--with-http_sub_module \
--with-http_realip_module \
--add-module=/www/server/source/fastdfs-nginx-module/src

make -j${cpuCore} && make install && make clean


service openresty restart


# 查看安装信息
# /www/server/openresty/bin/openresty -V
