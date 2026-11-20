FROM alpine:latest

ENV TZ=Europe/Stockholm
ENV LUA_PATH="/opt/pimon/lua/?.lua;/opt/pimon/lua/?/init.lua;;"

# procps-ng provides vmstat (busybox has none); busybox supplies crond, df, awk, find.
# lsqlite3 and dkjson are luarocks, not apk packages. Alpine ships one luarocks package
# per Lua version (luarocks5.1, binary luarocks-5.1). Rocks install under /usr/local,
# which LuaJIT searches by default. Build tooling is removed in the same layer.
RUN apk add --no-cache luajit sqlite gnuplot procps-ng tzdata \
    && apk add --no-cache --virtual .build luarocks5.1 build-base luajit-dev sqlite-dev unzip curl \
    && luarocks-5.1 install lsqlite3 LUA_INCDIR=/usr/include/luajit-2.1 \
    && luarocks-5.1 install dkjson \
    && apk del .build

WORKDIR /opt/pimon

COPY lua ./lua
COPY plots ./plots
COPY tests ./tests
COPY make_plots.sh backup.sh ./
# busybox crond reads /etc/crontabs/<user>; the file must not be group/world writable.
COPY crontab /etc/crontabs/root
COPY entrypoint.sh ./entrypoint.sh

RUN chmod +x /opt/pimon/make_plots.sh \
    && chmod +x /opt/pimon/backup.sh \
    && chmod +x /opt/pimon/lua/*.lua \
    && chmod 0600 /etc/crontabs/root \
    && mkdir -p /var/www/html/pimon \
    && mkdir -p /opt/pimon/backups \
    && mkdir -p /opt/pimon/archive \
    && chmod +x /opt/pimon/entrypoint.sh

CMD ["/opt/pimon/entrypoint.sh"]
