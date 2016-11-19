FROM alpine
MAINTAINER wangbin <wangbin253@gmail.com>

RUN export NGX_VER="1.10.1" && \

    addgroup -S -g 101 nginx && \
    adduser -HS -u 100 -h /data/www -s /sbin/nologin -G nginx nginx && \
    adduser nginx nginx && \

    # Prepare build tools for compiling some applications from source code
    apk --update add \
        openssl-dev \
        pcre-dev \
        zlib-dev \
        build-base \
        autoconf \
        libtool \
        && \

    # Download nginx and its modules source code
    wget -qO- http://nginx.org/download/nginx-${NGX_VER}.tar.gz | tar xz -C /tmp/ && \

    # Make and install nginx with module
    cd /tmp/nginx-${NGX_VER} && \
    ./configure --prefix=/usr/share/nginx --sbin-path=/usr/sbin/nginx --conf-path=/etc/nginx/nginx.conf \
      --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --pid-path=/var/run/nginx/nginx.pid \
      --lock-path=/var/run/nginx/nginx.lock --http-client-body-temp-path=/var/lib/nginx/tmp/client_body \
      --http-proxy-temp-path=/var/lib/nginx/tmp/proxy --http-fastcgi-temp-path=/var/lib/nginx/tmp/fastcgi \
      --http-uwsgi-temp-path=/var/lib/nginx/tmp/uwsgi --http-scgi-temp-path=/var/lib/nginx/tmp/scgi \
      --user=nginx --group=nginx --with-pcre-jit --with-http_ssl_module --with-http_realip_module \
      --with-http_addition_module --with-http_sub_module --with-http_dav_module  \
      --with-http_gunzip_module --with-http_gzip_static_module --with-http_random_index_module \
      --with-http_secure_link_module --with-http_stub_status_module --with-http_auth_request_module --with-mail \
      --with-http_v2_module --with-ipv6 --with-threads --with-stream --with-stream_ssl_module \
      --with-ld-opt="-Wl,-rpath,/usr/lib/" \
      && make -j2 && make install && \

    mkdir -p /var/lib/nginx/tmp && \
    chmod 755 /var/lib/nginx && \
    chmod -R 777 /var/lib/nginx/tmp && \
    mkdir -p /etc/nginx/pki && \
    chmod 400 /etc/nginx/pki && \

    # Cleanup
    apk del *-dev build-base autoconf libtool && \
    rm -rf /var/cache/apk/* /tmp/*

COPY rootfs /
