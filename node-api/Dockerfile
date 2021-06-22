FROM node:latest
ADD node_modules /node-api/node_modules/
ADD bin /node-api/bin/
ADD src /node-api/src
#RUN npm install -g node-inspector
#RUN npm install pm2 -g
#RUN npm install express
#RUN npm install ip
#RUN npm install babel -g
#RUN npm install --save-dev gulp-babel babel-preset-es2015
#RUN npm install nodemon -g

FROM node:12.14-alpine

ENV TZ Asia/Seoul
RUN	apk update && apk upgrade && \
	apk add --update tzdata && \
	cp /usr/share/zoneinfo/${TZ} /etc/localtime && \
	echo "${TZ}" > /etc/timezone

WORKDIR /usr/src/app

COPY . .

RUN rm -rf node_modules

RUN yarn
RUN yarn build

EXPOSE 80
CMD [ "yarn", "start:prod" ]