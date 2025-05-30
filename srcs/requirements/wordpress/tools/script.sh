#!/bin/bash

echo "Waiting for MariaDB to be ready..."
sleep 5

# First, test if the MariaDB port is reachable
echo "Testing if MariaDB port is reachable..."
max_port_attempts=30
port_attempt=1
while [ $port_attempt -le $max_port_attempts ]; do
    if nc -z $DB_HOST 3306 2>/dev/null; then
        echo "MariaDB port 3306 is reachable!"
        break
    else
        echo "Port attempt $port_attempt: MariaDB port not reachable, waiting..."
        sleep 2
        port_attempt=$((port_attempt + 1))
    fi
done

if [ $port_attempt -gt $max_port_attempts ]; then
    echo "ERROR: MariaDB port never became reachable"
    exit 1
fi

# Show connection parameters for debugging
echo "Connection parameters:"
echo "DB_HOST: $DB_HOST"
echo "DB_NAME: $DB_NAME" 
echo "DB_USER: $DB_USER"
echo "DB_PASSWORD: [${#DB_PASSWORD} characters]"

max_attempts=30
attempt=1
while [ $attempt -le $max_attempts ]; do
    if mysql -h $DB_HOST -u $DB_USER -p$DB_PASSWORD -e "SELECT 1" >/dev/null 2>&1; then
        echo "Database connection successful!"
        break
    else
        echo "Attempt $attempt: Database not ready, waiting..."
        sleep 2
        attempt=$((attempt + 1))
    fi
done

if [ $attempt -gt $max_attempts ]; then
    echo "Failed to connect to database after $max_attempts attempts"
    exit 1
fi

mkdir -p /var/www
mkdir -p /var/www/html
chown -R www-data:www-data /var/www/html

if [ ! -f /var/www/html/wp-config.php ]; then

	wp core download --allow-root --path=/var/www/html

	wp config create \
		--dbname=$DB_NAME \
		--dbuser=$DB_USER \
		--dbpass=$DB_PASSWORD \
		--dbhost=$DB_HOST \
		--allow-root \
		--path=/var/www/html \
		--skip-check

	wp core install \
		--title=$WP_TITLE \
		--url=$DOMAIN_NAME \
		--admin_user=$WP_ADMIN \
		--admin_password=$WP_ADMIN_PASSWORD \
		--admin_email=$WP_ADMIN_EMAIL \
		--path=/var/www/html \
		--allow-root

	if [ -n "$WP_USER_LOGIN" ] && [ -n "$WP_USER_EMAIL" ] && [ -n "$WP_USER_PASSWORD" ]; then
		wp user create "$WP_USER_LOGIN" "$WP_USER_EMAIL" \
			--user_pass=$WP_USER_PASSWORD \
			--path=/var/www/html \
			--allow-root
	fi
	
	wp theme install twentyfifteen --path=/var/www/html --allow-root
	wp theme activate twentyfifteen --path=/var/www/html --allow-root
	wp theme update twentyfifteen --path=/var/www/html --allow-root
	echo "Successfully installed wordpress"
fi

/usr/sbin/php-fpm8.2 -F
