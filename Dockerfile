FROM debian:jessie

MAINTAINER Krzysztof Kardasz <krzysztof@kardasz.eu>

# Update system and install required packages
ENV DEBIAN_FRONTEND noninteractive

# Use the default unprivileged account. This could be considered bad practice
# on systems where multiple processes end up being executed by 'daemon' but
# here we only ever run one process anyway.
ENV PHP_USER            php-data
ENV PHP_USER_UID        4545
ENV PHP_GROUP           php-data
ENV PHP_GROUP_GID       4545
ENV XDEBUG_ENABLED      0

RUN \
    apt-get update && \
    apt-get -y install curl autoconf file g++ gcc libc-dev make pkg-config re2c wget ca-certificates

RUN \
    echo 'deb http://apt.newrelic.com/debian/ newrelic non-free' | tee /etc/apt/sources.list.d/newrelic.list && \
    wget -O- https://download.newrelic.com/548C16BF.gpg | apt-key add -

RUN \
    echo 'deb http://packages.dotdeb.org jessie all' > /etc/apt/sources.list.d/dotdeb.list && \
    echo 'deb-src http://packages.dotdeb.org jessie all' >> /etc/apt/sources.list.d/dotdeb.list && \
    wget -O- https://www.dotdeb.org/dotdeb.gpg | apt-key add -

RUN \
    apt-get update && \
    apt-get -y install \
               libpcre3 libpcre3-dev librecode0 libsqlite3-0 libxml2 imagemagick \
               php7.0 php7.0-apcu php7.0-bz2 php7.0-cli php7.0-common php7.0-curl php7.0-dbg php7.0-dev  \
               php7.0-fpm php7.0-gd php7.0-geoip php7.0-igbinary php7.0-imagick php7.0-imap php7.0-intl \
               php7.0-json php7.0-ldap php7.0-mcrypt php7.0-memcached php7.0-mongodb php7.0-mysql php7.0-opcache \
               php7.0-pgsql php7.0-readline php7.0-redis php7.0-sqlite php7.0-xmlrpc newrelic-php5 && \
    apt-get clean autoclean && \
    apt-get autoremove --yes && \
    rm -rf /var/lib/{apt,dpkg,cache,log}/

RUN \
    wget -O /usr/local/bin/apigen http://apigen.org/apigen.phar && chmod +x /usr/local/bin/apigen && \
    curl -sS https://getcomposer.org/installer | /usr/bin/php -- --install-dir=/usr/local/bin --filename=composer && \
    wget -O /usr/local/bin/phpdoc http://phpdoc.org/phpDocumentor.phar && chmod +x /usr/local/bin/phpdoc && \
    wget -O /usr/local/bin/phpunit https://phar.phpunit.de/phpunit.phar && chmod +x /usr/local/bin/phpunit && \
    curl -LsS http://symfony.com/installer > /usr/local/bin/symfony && chmod a+x /usr/local/bin/symfony && \
    wget -O /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && chmod +x /usr/local/bin/wp && \
    mkdir -p /usr/local/share/wordpress && wget -O /usr/local/share/wordpress/wp_completion https://github.com/wp-cli/wp-cli/raw/master/utils/wp-completion.bash

RUN \
    rm -rf /etc/php/7.0/fpm/conf.d && ln -s /etc/php/mods-available /etc/php/7.0/fpm/conf.d && \
    rm -rf /etc/php/7.0/cli/conf.d && ln -s /etc/php/mods-available /etc/php/7.0/cli/conf.d

RUN mkdir -p /var/log/php

# forward logs to docker log collector
RUN ln -sf /dev/stderr /var/log/php7.0-fpm.log

COPY docker-entrypoint.sh /entrypoint.sh
COPY etc/php-fpm.conf /etc/php/7.0/fpm/php-fpm.conf

RUN chmod a+x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 9000

CMD ["php-fpm7.0", "-c", "/etc/php/7.0/fpm", "--fpm-config", "/etc/php/7.0/fpm/php-fpm.conf", "-F", "-O"]
