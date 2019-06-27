FROM ubuntu:latest

ARG PHP_VERSION=7.3

COPY ./scripts/autoclean.sh /root/
COPY ./scripts/docker-entrypoint.sh ./cron/cronfile /

RUN echo $PHP_VERSION > /PHP_VERSION; \
    chmod +x /root/autoclean.sh; \
    chmod +x /docker-entrypoint.sh; \
    mkdir /app; \
    mkdir /run/php/; \
    apt-get update; \
    apt-get install -y software-properties-common \
        apt-transport-https \
        cron \
        ssmtp \
        unzip \
        curl; \
    add-apt-repository -y ppa:ondrej/php; \
    export DEBIAN_FRONTEND=noninteractive; \
    apt-get install -yq \
        mariadb-client \
        php$PHP_VERSION \
        php$PHP_VERSION-cli \
        php$PHP_VERSION-common \
        php$PHP_VERSION-curl \
        php$PHP_VERSION-fpm \
        php$PHP_VERSION-json \
        php$PHP_VERSION-mysql \
        php$PHP_VERSION-opcache \
        php$PHP_VERSION-readline \
        php$PHP_VERSION-xml \
        php$PHP_VERSION-xsl \
        php$PHP_VERSION-gd \
        php$PHP_VERSION-intl \
        php$PHP_VERSION-bz2 \
        php$PHP_VERSION-bcmath \
        php$PHP_VERSION-imap \
        php$PHP_VERSION-gd \
        php$PHP_VERSION-mbstring \
        php$PHP_VERSION-pgsql \
        php$PHP_VERSION-sqlite3 \
        php$PHP_VERSION-xmlrpc \
        php$PHP_VERSION-zip \
        php$PHP_VERSION-odbc \
        php$PHP_VERSION-snmp \
        php$PHP_VERSION-interbase \
        php$PHP_VERSION-ldap \
        php$PHP_VERSION-tidy \
        php$PHP_VERSION-memcached \
        php-tcpdf \
        php-redis \
        php-imagick; \
        /usr/bin/unattended-upgrades -v;

COPY ./ssmtp/ssmtp.conf /etc/ssmtp/

COPY ./php/php-fpm.conf ./php/php.ini /etc/php/$PHP_VERSION/fpm/
COPY ./php/www.conf /etc/php/$PHP_VERSION/fpm/pool.d/

ENTRYPOINT ["/docker-entrypoint.sh"]
