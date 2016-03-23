#!/bin/bash
set -e

if [ "$1" = 'php5-fpm' ]; then
    if [ -z "$(getent passwd $PHP_USER)" ]; then
      echo "Creating user $PHP_USER:$PHP_GROUP"

      groupadd --gid ${PHP_GROUP_GID} -r ${PHP_GROUP} && \
      useradd -r --uid ${PHP_USER_UID} -g ${PHP_GROUP} -d /var/www ${PHP_USER}
    fi

    if [ ! -d /var/log/php ]; then
      mkdir -p /var/log/php
      chown $PHP_USER:$PHP_GROUP /var/log/php
    fi
fi

exec "$@"
