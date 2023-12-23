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
    xml

COPY . /app

RUN apt-get update
RUN apt-get -y --no-install-recommends install npm

RUN php artisan migrate
RUN npm install
RUN npm run build

RUN php artisan event:cache
RUN php artisan route:cache
RUN php artisan view:cache
