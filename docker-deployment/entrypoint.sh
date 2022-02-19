#!/bin/bash

composer dump-autoload --optimize

php artisan config:cache

php artisan route:cache

php artisan optimize

a2enmod rewrite

exec "$@"
