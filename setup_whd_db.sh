#!/bin/bash
DB_NAME=whd
DB_ADMIN_USER=whddbadmin
DB_ADMIN_PASS=admin123
DB_USER=whd
DB_PASS=whd
rm -rf /usr/local/webhelpdesk/bin/pgsql
dnf install -y postgresql
# PSQL_PATH=`find / -name psql -print`
PSQL_PATH-/usr/bin/psql
if [ ! -z "$PSQL_PATH" ]
then
   # until $PSQL_PATH -h postgres-whd -U postgres -c '\l'; do
   until $PSQL_PATH -h $DB_HOST -U postgres -c '\l'; do
   >&2 echo "Postgres is unavailable - sleeping"
     sleep 1
   done 
   echo "setting up DB"
   echo "CREATE ROLE $DB_ADMIN_USER WITH LOGIN ENCRYPTED PASSWORD '${DB_ADMIN_PASS}' CREATEDB; \
      CREATE ROLE $DB_USER WITH LOGIN ENCRYPTED PASSWORD '${DB_PASS}' CREATEDB; \
      CREATE DATABASE $DB_NAME WITH OWNER $DB_ADMIN_USER TEMPLATE template0 ENCODING 'UTF8'; \
      GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $DB_ADMIN_USER, $DB_USER;" | $PSQL_PATH -h $DB_HOST -U postgres
   echo "done setting up DB"
fi

