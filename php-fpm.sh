#!/bin/sh
exec /sbin/setuser root /usr/sbin/php5-fpm >> /var/log/php-fpm.log 2>&1
