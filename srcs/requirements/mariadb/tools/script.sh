#!/bin/bash


Initialize database if not already
if [ ! -d "/var/lib/mysql/mysql" ]; then
  echo "Initializing database..."
  mariadb-install-db --user=mysql --datadir=/var/lib/mysql
fi

# Start MariaDB in the background
mysqld_safe --datadir='/var/lib/mysql' --bind-address=0.0.0.0 &

# Wait until MariaDB is ready
until mysqladmin ping --silent; do
  echo "Waiting for MariaDB to start..."
  sleep 2
done

echo "MariaDB is up. Configuring..."

# Create user, database, and grant privileges
mysql -u root -p"password" <<EOF
CREATE DATABASE IF NOT EXISTS ${DB_NAME};
CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY 'password';
FLUSH PRIVILEGES;
EOF

if [ $? -eq 0 ]; then
    echo "Database configuration completed successfully"
    echo "Database: ${DB_NAME}"
    echo "User: ${DB_USER}"
    echo "Testing connection..."
    mysql -u ${DB_USER} -p${DB_PASSWORD} -e "SELECT 1;" ${DB_NAME}
    if [ $? -eq 0 ]; then
        echo "User connection test successful"
    else
        echo "ERROR: User connection test failed"
    fi
else
    echo "ERROR: Database configuration failed"
fi
# Keep MariaDB in the foreground
wait
#
# service mysql start 
#
#
# echo "CREATE DATABASE IF NOT EXISTS $db1_name ;" > db1.sql
# echo "CREATE USER IF NOT EXISTS '$db1_user'@'%' IDENTIFIED BY '$db1_pwd' ;" >> db1.sql
# echo "GRANT ALL PRIVILEGES ON $db1_name.* TO '$db1_user'@'%' ;" >> db1.sql
# echo "ALTER USER 'root'@'localhost' IDENTIFIED BY '12345' ;" >> db1.sql
# echo "FLUSH PRIVILEGES;" >> db1.sql
#
# mysql < db1.sql
#
# kill $(cat /var/run/mysqld/mysqld.pid)
#
# mysqld
