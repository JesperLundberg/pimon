FROM alpine:latest

ENV TZ=Europe/Stockholm
# Alpine's lua5.1-* packages install outside LuaJIT's default search paths.
ENV LUA_PATH="/opt/pimon/lua/?.lua;/opt/pimon/lua/?/init.lua;/usr/share/lua/5.1/?.lua;/usr/share/lua/5.1/?/init.lua;;"
ENV LUA_CPATH="/usr/lib/lua/5.1/?.so;;"

# procps-ng provides vmstat (busybox has none); busybox supplies crond, df, awk, find.
RUN apk add --no-cache \
        luajit \
        lua5.1-lsqlite3 \
        lua5.1-dkjson \
        sqlite \
        gnuplot \
        procps-ng \
        tzdata

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
