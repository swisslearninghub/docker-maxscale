#!/bin/bash

set -e

# if service discovery was activated, we overwrite the BACKEND_SERVER_LIST with the
# results of DNS service lookup
if [ -n "$DB_SERVICE_NAME" ]; then
  BACKEND_SERVER_LIST=`getent hosts tasks.$DB_SERVICE_NAME|awk '{print $1}'|tr '\n' ' '`
fi



# We break our IP list into array
IFS=', ' read -r -a backend_servers <<< "$BACKEND_SERVER_LIST"


config_file="/etc/maxscale.cnf"

# We start config file creation

cat <<EOF > $config_file
[maxscale]
threads=$MAX_THREADS
admin_secure_gui = false
admin_host = 0.0.0.0

[Galera Service]
type=service
router=readconnroute
router_options=$ROUTER_OPTIONS
servers=${BACKEND_SERVER_LIST// /,}
connection_timeout=$CONNECTION_TIMEOUT
user=$MAX_USER
passwd=$MAX_PASS
enable_root_user=$ENABLE_ROOT_USER

[Galera Listener]
type=listener
service=Galera Service
protocol=MariaDBClient
port=$ROUTER_PORT

[Splitter Service]
type=service
router=readwritesplit
servers=${BACKEND_SERVER_LIST// /,}
connection_timeout=$CONNECTION_TIMEOUT
user=$MAX_USER
passwd=$MAX_PASS
enable_root_user=$ENABLE_ROOT_USER
use_sql_variables_in=$USE_SQL_VARIABLES_IN

[Splitter Listener]
type=listener
service=Splitter Service
protocol=MariaDBClient
port=$SPLITTER_PORT

[Galera Monitor]
type=monitor
;module=galeramon
module=mariadbmon
servers=${BACKEND_SERVER_LIST// /,}
disable_master_failback=1
user=$MAX_USER
passwd=$MAX_PASS

[CLI]
type=service
router=cli
[CLI Listener]
type=listener
service=CLI
protocol=maxscaled
port=6603

# Start the Server block
EOF

# add the [server] block
for i in ${!backend_servers[@]}; do
cat <<EOF >> $config_file
[${backend_servers[$i]}]
type=server
address=${backend_servers[$i]}
port=$BACKEND_SERVER_PORT
protocol=MariaDBBackend
persistpoolmax=$PERSIST_POOLMAX
persistmaxtime=$PERSIST_MAXTIME

EOF

done


exec "$@"

