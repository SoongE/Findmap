FROM node:latest

ENV TZ Asia/Seoul
RUN	apt-get update && apt-get -y upgrade && \
	apt-get install tzdata && \
	cp /usr/share/zoneinfo/${TZ} /etc/localtime && \
	echo "${TZ}" > /etc/timezone

#RUN mkdir -p /server
WORKDIR /root
COPY . .

ENV DEVIAN_FRONTEND=noninteractive
ENV NODE_ENV production

RUN npm install

EXPOSE 8080
ENTRYPOINT [ "npm", "run", "start" ]
#CMD [ "yarn", "yarn start:prod" ]

