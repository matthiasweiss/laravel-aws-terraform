FROM dunglas/frankenphp

# https://laravel.com/docs/10.x/deployment#server-requirements
RUN install-php-extensions \
    ctype \
    curl \
    dom \
    fileinfo \
    filter \
    hash \
    mbstring \
    openssl \
    pcre \
    pdo_mysql \
    session \
    tokenizer \
    xml \
    zip

COPY . /app

RUN apt-get update
RUN apt-get -y --no-install-recommends install npm git unzip

COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer
RUN composer install --no-scripts

RUN npm install
RUN npm run build

COPY ./scripts/docker-entrypoint.sh ./docker-entrypoint.sh
CMD ./docker-entrypoint.sh
