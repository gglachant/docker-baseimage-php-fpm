FROM gglachant/docker-baseimage-nginx:latest

MAINTAINER Gabriel Glachant <gglachant@gmail.com>

ENV DEBIAN_FRONTEND noninteractive
ENV HOME /root
ENV PHP_FPM_PACKAGE_VERSION 5.5.9+dfsg-1ubuntu4.14

RUN apt-get -qy update && \
 apt-get -qy install php5-fpm=$PHP_FPM_PACKAGE_VERSION && \
 apt-get -qy clean && \
 rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# php-fpm config
RUN sed -i -e "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g" /etc/php5/fpm/php.ini
RUN sed -i -e "s/;catch_workers_output\s*=\s*yes/catch_workers_output = yes/g" /etc/php5/fpm/pool.d/www.conf

COPY build/service-php-fpm.sh /etc/service/php-fpm/run

COPY build/nginx-default /etc/nginx/sites-available/default

EXPOSE 80

CMD ["/sbin/my_init"]
