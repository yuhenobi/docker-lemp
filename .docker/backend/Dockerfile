FROM ubuntu:xenial
MAINTAINER Yuhenobi <obi@yuhen.ru>

RUN echo "deb http://ppa.launchpad.net/ondrej/php/ubuntu xenial main \
  deb-src http://ppa.launchpad.net/ondrej/php/ubuntu xenial main" >> /etc/apt/sources.list.d/ondrej-php7.list \
  && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4F4EA0AAE5267A6C

ARG PHP_VERSION

RUN apt-get update && apt-get install -y \
  php${PHP_VERSION}-dev \
  php${PHP_VERSION}-cli \
  php${PHP_VERSION}-fpm \
  php${PHP_VERSION}-curl \
  php${PHP_VERSION}-gd \
  php${PHP_VERSION}-bcmath \
  php${PHP_VERSION}-ctype \
  php${PHP_VERSION}-json \
  php${PHP_VERSION}-mbstring \
  php${PHP_VERSION}-pdo \
  php${PHP_VERSION}-tokenizer \
  php${PHP_VERSION}-xml \
  php${PHP_VERSION}-pgsql \
  php${PHP_VERSION}-mysql \
  php${PHP_VERSION}-memcache \
  php${PHP_VERSION}-xdebug \
  php-pear \
  supervisor \
  nginx-full \
  wget \
  curl \
  dnsutils \
  gdb \
  git \
  htop \
  iproute2 \
  iputils-ping \
  ltrace \
  make \
  procps \
  strace \
  sudo \
  sysstat \
  openssh-server \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/* /var/log/lastlog /var/log/faillog \
  && touch /run/php-fpm.sock && chown www-data:www-data /run/php-fpm.sock \
  && mkdir /var/run/sshd

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Add SSH key to authorized_keys
COPY ./backend/.ssh/id_docker.pub /tmp/id_docker.pub
RUN mkdir -p ~/.ssh \
  && cat /tmp/id_docker.pub >> ~/.ssh/authorized_keys \
  && chown -R ${APP_USER}: ~/.ssh \
  && chmod 700 ~/.ssh \
  && chmod 600 ~/.ssh/authorized_keys

# Setup the proper timezone
ARG TIMEZONE
RUN ln -snf /usr/share/zoneinfo/${TIMEZONE} /etc/localtime && echo ${TIMEZONE} > /etc/timezone

# Configure Nginx
COPY ./backend/nginx/nginx.conf /etc/nginx/
ARG APP_USER
ARG APP_GROUP
RUN sed -i -e "s#__NGINX_USER#${APP_USER}#g" /etc/nginx/nginx.conf
RUN sed -i -e "s#__NGINX_GROUP#${APP_GROUP}#g" /etc/nginx/nginx.conf

COPY ./backend/nginx/sites-available/* /etc/nginx/sites-available/
ARG APP_HOST
ARG NGINX_ROOT
RUN sed -i -e "s#__NGINX_SERVER_NAME#${APP_HOST}#g" /etc/nginx/sites-available/default
RUN sed -i -e "s#__NGINX_ROOT#${NGINX_ROOT}#g" /etc/nginx/sites-available/default

# Configure PHP-FPM
COPY ./backend/php/php-fpm.conf /etc/php/${PHP_VERSION}/fpm/php-fpm.conf
RUN sed -i -e "s#__PHP_VERSION#${PHP_VERSION}#g" /etc/php/${PHP_VERSION}/fpm/php-fpm.conf

COPY ./backend/php/pool.d/www.conf /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf
RUN sed -i -e "s#__APP_USER#${APP_USER}#g" /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf
RUN sed -i -e "s#__APP_GROUP#${APP_GROUP}#g" /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf
RUN sed -i -e "s#__NGINX_ROOT#${NGINX_ROOT}#g" /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf

COPY ./backend/php/php.ini /etc/php/${PHP_VERSION}/fpm/php.ini
RUN sed -i -e "s#__TIMEZONE#${TIMEZONE}#g" /etc/php/${PHP_VERSION}/fpm/php.ini

# Configure Supervisor
COPY ./backend/supervisor/supervisord.conf /etc/supervisor/
COPY ./backend/supervisor/conf.d/* /etc/supervisor/conf.d/
RUN sed -i -e "s#__PHP_VERSION#${PHP_VERSION}#g" /etc/supervisor/conf.d/backend.conf

# Create project folder and change ownership
ARG APP_CODE_PATH_CONTAINER
RUN mkdir ${APP_CODE_PATH_CONTAINER} \
  && chown -R www-data:www-data ${APP_CODE_PATH_CONTAINER}

# Setting the work directory
WORKDIR ${APP_CODE_PATH_CONTAINER}

# Expose ports for Nginx and SSH
ARG NGINX_HOST_HTTP_PORT
EXPOSE ${NGINX_HOST_HTTP_PORT}

# Run Supervisor to serve them all!
CMD ["/usr/bin/supervisord"]