FROM enoniccloud/apache2-letsencrypt

RUN a2enmod proxy_wstunnel \
  && a2enmod proxy_http \
  && a2enmod rewrite \
  && a2enmod headers

COPY sites /etc/apache2/sites-enabled
