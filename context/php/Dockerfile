FROM php:7.4-fpm

ARG TIMEZONE
ARG XDBG_IDEKEY
ARG XDBG_REMOTE_PORT
ARG HOST_WWW_UID
ARG HOST_WWW_GID

# Make sure 'www-data' IDs map to a host user.
RUN usermod -u ${HOST_WWW_UID} www-data
RUN groupmod -g ${HOST_WWW_GID} www-data

# Install base utilities.
RUN apt update && apt install -y \
    vim \
    libicu-dev \
    libzip-dev \
    git \
    libpng-dev \
    gnupg2 \
    unzip \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    libpq-dev \
    msmtp \
    openssl \
    wget \
    libxpm-dev \
    libwebp-dev \
    && rm -rf /var/lib/apt/lists/*

ADD mail/msmtprc /etc/msmtprc
RUN chmod 600 /etc/msmtprc
RUN echo 'sendmail_path = "/usr/bin/msmtp -t"' > /usr/local/etc/php/conf.d/mail.ini

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN composer --version

RUN composer global require "squizlabs/php_codesniffer=*" \
    && composer global require friendsofphp/php-cs-fixer \
    && composer global require --dev phpstan/phpstan

# Add global composer binaries to the path.
ENV PATH="/root/.composer/vendor/bin/:${PATH}"

# Test PHP tools installs
RUN phpstan --version \
    && php-cs-fixer --version \
    && phpcs --version

# Install code sniffer for Drupal (with coder)
# RUN composer global require drupal/coder \
#    && export PATH="/root/.composer/vendor/bin" \
#    && phpcs --config-set installed_paths ~/.composer/vendor/drupal/coder/coder_sniffer \
#    && phpcs -i

# Set timezone
RUN ln -snf /usr/share/zoneinfo/${TIMEZONE} /etc/localtime && echo ${TIMEZONE} > /etc/timezone
RUN printf '[PHP]\ndate.timezone = "%s"\n', ${TIMEZONE} > /usr/local/etc/php/conf.d/tzone.ini
RUN "date"

# Yarn is usefull with a symfony project if you want to install Webpack encore
# RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
#    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
#    && apt update \
#    && apt install -y yarn \
#    && yarn --version

RUN  mkdir -p /usr/share/man/man1 \
    && mkdir -p /usr/share/man/man7

# If PostgreSQL
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ buster-pgdg main" | tee /etc/apt/sources.list.d/pgdg.list \
    && wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
    && apt update \
    && apt install -y postgresql-client \
    && docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql \
    && docker-php-ext-install pdo pdo_pgsql pgsql

# If MariaDB
# RUN apt install -y mariadb-client \
   # && docker-php-ext-install pdo pdo_mysql

RUN rm -rf /var/lib/apt/lists/*

# Install other php extensions
RUN docker-php-ext-install opcache \
    && docker-php-ext-configure opcache --enable-opcache

RUN docker-php-ext-configure gd \
        --with-freetype=/usr/include \
        --with-jpeg=/usr/include \
        --with-xpm=/usr/include \
        --with-webp=/usr/include \
    && docker-php-ext-install gd

RUN docker-php-ext-install zip intl exif

# Disable memory_limit
RUN echo 'memory_limit = -1' >> /usr/local/etc/php/conf.d/docker-php-memlimit.ini

# Install and configure xdebug.
RUN pecl install xdebug
RUN docker-php-ext-enable xdebug
RUN echo "error_reporting = E_ALL" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
RUN echo "display_startup_errors = On" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
RUN echo "display_errors = On" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
RUN echo "xdebug.remote_enable=1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
RUN echo "xdebug.remote_connect_back=1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
RUN echo "xdebug.idekey=\"${XDBG_IDEKEY}\"" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
RUN echo "xdebug.remote_port=${XDBG_REMOTE_PORT}" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
RUN echo "xdebug.max_nesting_level=10000" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

WORKDIR /var/www/code

# Aliases.
RUN echo 'alias ll="ls -alh"' >> ~/.bashrc
