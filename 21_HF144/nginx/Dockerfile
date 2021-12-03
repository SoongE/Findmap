FROM nginx
LABEL maintainer="Rhcsky <dev.rhcsky@gmail.com>"

COPY ./scripts/ /scripts
RUN chmod +x /scripts/*.sh

RUN rm -f /etc/nginx/conf.d/*
COPY ./user.conf.d/ /etc/nginx/user.conf.d/

CMD ["/bin/bash", "/scripts/entrypoint.sh"]
