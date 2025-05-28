from debian:bookworm

RUN apt-get update -y && \
	apt-get install -y \
	php-mysql \
	php-fpm \
	php-zip \
	php-cli \
	php-curl \
	curl \
	&& sed -i s|^listen = .*|listen = 9000|' /etc/php/8.2/fpm/pool.d/www.conf \
	&& sed -i s|^cliear_env = .*|clear_env = no|' /etc/php/8.2/fpm/pool.d/www.conf

RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

RUN wp core download --allow-root --path=/var/www/html

RUN chown -R www-data:www-data /var/www/html \
	&& chmod -R 755 /var/www/html

RUN mkdir -p /run/php

COPY ./tools/script.sh /
RUN chmod +x /script.sh

CMD ["/script.sh"]
