const express = require('./modules/express');
const {logger} = require('./modules/winston');

const port = 3000;
express().listen(port);
logger.info(`${process.env.NODE_ENV} - API Server Start At Port ${port}`);