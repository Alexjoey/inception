#!/bin/bash

until mysqladmin ping -h"$DB_HOST" -u"$DB_USER" -p"$DB_PASSWRD" --silent; do
	echo "Waiting for mariadb connection"
	sleep 2
done

if [ ! -f /var/www/html/wp-config.php ]; then
	wp config create \
		--dbname=$DB_NAME \
		--dbuser=$DB_USER \
		--dbpass=$DB_PASSWORD \
		--dbhost=$DB_HOST \
		--allow-root \
		--skip-check

	wp core install \
		--url=$DOMAIN_NAME \
		--title=$BRAND \
		--admin_user=$WP_ADMIN \
		--admin_password=$WP_ADMIN_PASSWORD \
		--admin_email=$WP_ADMIN_EMAIL \
		--allow-root

	if [ -n "$WP_USER_LOGIN" ] && [ -n "$WP_USER_EMAIL" ] && [ -n "$WP_USER_PASSWORD" ]; then
		wp user create "$WP_USER_LOGIN" "$WP_USER_EMAIL" \
			--user_pass=$WP_USER_PASSWORD \
			--allow-root
	fi
	
	wp theme install twentyfifteen
	wp theme activate twentyfifteen
	wp theme update twentyfifteen
fi

/usr/sbin/php-fpm8.2 -F
