FROM nginx
LABEL maintainer="Rhcsky <dev.rhcsky@gmail.com>"

EXPOSE 80

COPY ./scripts/ /scripts
RUN chmod +x /scripts/*.sh

COPY ./user.conf.d/ /etc/nginx/user.conf.d/ 

CMD ["/bin/bash"]
# CMD ["/bin/bash", "/scripts/entrypoint.sh"]