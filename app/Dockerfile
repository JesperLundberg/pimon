FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Stockholm
ENV LUA_PATH="/opt/pimon/lua/?.lua;/opt/pimon/lua/?/init.lua;;"

RUN apt-get update &&     apt-get install -y --no-install-recommends \
        luajit \
        luarocks \
        sqlite3 \
        gnuplot-nox \
        vmstat \
        curl \
        cron \
        tzdata \
        build-essential \
        libsqlite3-dev && \
    luarocks --lua-version=5.1 install lsqlite3 && \
    luarocks --lua-version=5.1 install dkjson && \
    apt-get remove -y build-essential libsqlite3-dev && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /opt/pimon

COPY lua ./lua
COPY plots ./plots
COPY make_plots.sh ./
COPY crontab /etc/cron.d/pimon
COPY entrypoint.sh ./entrypoint.sh

RUN chmod +x /opt/pimon/make_plots.sh \
    && chmod +x /opt/pimon/lua/*.lua \
    && chmod 0644 /etc/cron.d/pimon \
    && mkdir -p /var/www/html/pimon \
    && mkdir -p /opt/pimon/backups \
    && mkdir -p /opt/pimon/archive \
    && chmod +x /opt/pimon/entrypoint.sh \
    && touch /var/log/cron.log

CMD ["/opt/pimon/entrypoint.sh"]
