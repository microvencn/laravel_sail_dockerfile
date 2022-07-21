FROM ubuntu:21.10

LABEL maintainer="Taylor Otwell"

ARG WWWGROUP

WORKDIR /var/www/html

ENV DEBIAN_FRONTEND noninteractive
ENV TZ=Asia/Shanghai
ENV APT_MIRROR http://mirrors.ustc.edu.cn
ENV XLSWRITER_VERSION 1.5.2

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN echo 'APT::Acquire::Retries "5";' > /etc/apt/apt.conf.d/80-retries \
  && sed -i "s|http://archive.ubuntu.com|$APT_MIRROR|g; s|http://security.ubuntu.com|$APT_MIRROR|g" /etc/apt/sources.list \
  && sed -i "s|http://ports.ubuntu.com|$APT_MIRROR|g" /etc/apt/sources.list \
  && apt-get update

RUN apt-get update \
    # 基础配置
    && apt-get install -y gnupg gosu curl ca-certificates zip unzip git supervisor sqlite3 libcap2-bin libpng-dev python2 \
    && mkdir -p ~/.gnupg \
    && chmod 600 ~/.gnupg \
    && echo "disable-ipv6" >> ~/.gnupg/dirmngr.conf \
    && apt-key adv --homedir ~/.gnupg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys E5267A6C \
    && apt-key adv --homedir ~/.gnupg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys C300EE8C \
    && echo "deb https://launchpad.proxy.ustclug.org/ondrej/php/ubuntu impish main" > /etc/apt/sources.list.d/ppa_ondrej_php.list \
    && apt-get update

    # npm
RUN apt-get install -y nodejs npm \
    && npm config set registry https://registry.npm.taobao.org \
    && npm install n -g \
    && n stable

    # php
RUN apt-get install -y php8.1-cli php8.1-dev \
       php8.1-pgsql php8.1-sqlite3 php8.1-gd \
       php8.1-curl \
       php8.1-imap php8.1-mysql php8.1-mbstring \
       php8.1-xml php8.1-zip php8.1-bcmath php8.1-soap \
       php8.1-intl php8.1-readline \
       php8.1-ldap \
       php8.1-msgpack php8.1-igbinary php8.1-redis php8.1-swoole \
       php8.1-memcached php8.1-pcov php8.1-xdebug \
    && php -r "readfile('https://getcomposer.org/installer');" | php -- --install-dir=/usr/bin/ --filename=composer

    # yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" > /etc/apt/sources.list.d/yarn.list \
    && apt-get update \
    && apt-get install -y yarn \
    && yarn config set registry https://registry.npm.taobao.org \
    && apt-get install -y mysql-client \
    && apt-get install -y postgresql-client

    # XlsWriter 扩展
RUN echo yes | pecl install https://pecl.php.net/get/xlswriter-$XLSWRITER_VERSION.tgz \
    && apt-get -y autoremove \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN setcap "cap_net_bind_service=+ep" /usr/bin/php8.1

RUN groupadd --force -g $WWWGROUP sail
RUN useradd -ms /bin/bash --no-user-group -g $WWWGROUP -u 1337 sail

COPY start-container /usr/local/bin/start-container
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY php.ini /etc/php/8.1/cli/conf.d/99-sail.ini
RUN chmod +x /usr/local/bin/start-container

EXPOSE 8000

ENTRYPOINT ["start-container"]
