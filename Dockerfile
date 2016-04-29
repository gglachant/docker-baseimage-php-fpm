FROM gglachant/docker-baseimage-nginx:latest

MAINTAINER Gabriel Glachant <gglachant@gmail.com>

# Remove it. Add it when running apt-get only.
# ENV DEBIAN_FRONTEND noninteractive
ENV HOME /root
ENV PHP_FPM_PACKAGE_VERSION 5.5.9+dfsg-1ubuntu4.16

RUN echo '#!/bin/sh' > /usr/sbin/policy-rc.d \
 && echo 'exit 101' >> /usr/sbin/policy-rc.d \
 && chmod +x /usr/sbin/policy-rc.d \
 \
 && dpkg-divert --local --rename --add /sbin/initctl \
 && cp -a /usr/sbin/policy-rc.d /sbin/initctl \
 && sed -i 's/^exit.*/exit 0/' /sbin/initctl \
 \
 && echo 'force-unsafe-io' > /etc/dpkg/dpkg.cfg.d/docker-apt-speedup \
 \
 && echo 'DPkg::Post-Invoke { "rm -f /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb /var/cache/apt/*.bin || true"; };' > /etc/apt/apt.conf.d/docker-clean \
 && echo 'APT::Update::Post-Invoke { "rm -f /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb /var/cache/apt/*.bin || true"; };' >> /etc/apt/apt.conf.d/docker-clean \
 && echo 'Dir::Cache::pkgcache ""; Dir::Cache::srcpkgcache "";' >> /etc/apt/apt.conf.d/docker-clean \
 \
 && echo 'Acquire::Languages "none";' > /etc/apt/apt.conf.d/docker-no-languages \
 \
 && echo 'Acquire::GzipIndexes "true"; Acquire::CompressionTypes::Order:: "gz";' > /etc/apt/apt.conf.d/docker-gzip-indexes

# Enable the universe repositories
# RUN sed -i 's/^#\s*\(deb.*universe\)$/\1/g' /etc/apt/sources.list

# Fully update the system
# RUN apt-get update && apt-get -y upgrade && apt-get autoremove && apt-get clean

RUN export DEBIAN_FRONTEND=noninteractive \
 && apt-get -qy update \
 && apt-get -qy install php5-fpm=$PHP_FPM_PACKAGE_VERSION \
 && apt-get -qy clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# php-fpm config
RUN sed -i -e "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g" /etc/php5/fpm/php.ini
RUN sed -i -e "s/;catch_workers_output\s*=\s*yes/catch_workers_output = yes/g" /etc/php5/fpm/pool.d/www.conf

COPY build/service-php-fpm.sh /etc/service/php-fpm/run

COPY build/nginx-default /etc/nginx/sites-available/default

EXPOSE 80

CMD ["/sbin/my_init"]
