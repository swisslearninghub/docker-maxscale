FROM asosso/maxscale:2.2.5

# Setup for Galera Service (GS), not for Master-Slave environments

# We set some defaults for config creation. Can be overwritten at runtime.
ENV MAX_THREADS=4
ENV MAX_USER="maxscale"
ENV MAX_PASS="maxscalepass"
ENV ENABLE_ROOT_USER=0
ENV SPLITTER_PORT=3306
ENV ROUTER_PORT=3307
ENV ROUTER_OPTIONS="synced"
ENV CLI_PORT=6603
ENV CONNECTION_TIMEOUT=600
ENV PERSIST_POOLMAX=0
ENV PERSIST_MAXTIME=3600
ENV BACKEND_SERVER_LIST="server1 server2 server3"
ENV BACKEND_SERVER_PORT="3306"
ENV USE_SQL_VARIABLES_IN="all"

# We copy our config creator script to the container
COPY docker-entrypoint.sh /

# We expose our set Listener Ports
EXPOSE $SPLITTER_PORT $ROUTER_PORT $CLI_PORT 8989

# We define the config creator as entrypoint
ENTRYPOINT ["/docker-entrypoint.sh"]

# We startup MaxScale as default command
CMD ["/usr/bin/maxscale","--nodaemon"]
