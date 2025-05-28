#!/bin/bash

# change bind address to all so other containers can connect
sed -i 's/^bind-address\s*=.*/bind-address = 0.0.0.0/' /etc/mysql/mariadb.conf.d/50-server.cnf

# start in background
service mysql start

# make database, users, root user + password
cat << EOF > db1.sql
CREATE DATABASE IF NOT EXISTS $db1_name ;
CREATE USER IF NOT EXISTS '$db1_user'@'%' IDENTIFIED BY '$db1_pwd' ;
GRANT ALL PRIVILEGES ON $db1_name.* to '$db1_user'@'%' ;
ALTER USER 'root'@'localhost' IDENTIFIED BY 'password' ;
FLUSH PRIVILEGES;
EOF

mysql < db1.sql

# stop background sql
kill $(cat /var/run/mysqld/mysqld.pid)

# run it in foreground so container doesnt close
mysqld
