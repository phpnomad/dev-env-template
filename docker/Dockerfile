FROM wordpress:php8.1-apache

# Install necessary tools
RUN apt-get update && apt-get install -y wget unzip && rm -rf /var/lib/apt/lists/*

# Install PHPUnit
RUN wget -O phpunit https://phar.phpunit.de/phpunit-9.phar \
    && chmod +x phpunit \
    && mv phpunit /usr/local/bin/phpunit \