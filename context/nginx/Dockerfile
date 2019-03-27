FROM debian
ARG WEBAPP_DOMAIN

RUN apt-get update && apt-get install -y \
    nginx ca-certificates

ADD nginx.conf /etc/nginx/
ADD project.conf /etc/nginx/sites-available/

RUN sed -i "s/HOSTNAME/${WEBAPP_DOMAIN}/g" /etc/nginx/sites-available/project.conf

RUN ln -s /etc/nginx/sites-available/project.conf /etc/nginx/sites-enabled/project
RUN rm /etc/nginx/sites-enabled/default

RUN echo "upstream php-upstream { server php:9000; }" > /etc/nginx/conf.d/upstream.conf
RUN openssl req -x509 -newkey rsa:4096 -keyout /etc/nginx/nginx-selfsigned.key -out /etc/nginx/nginx-selfsigned.crt -days 365 -nodes -batch -subj "/CN=$WEBAPP_DOMAIN"

RUN usermod -u 1000 www-data
RUN echo 'alias ll="ls -alh"' >> ~/.bashrc

CMD ["nginx"]

EXPOSE 80
EXPOSE 443
