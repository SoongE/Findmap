const express = require('express');
const router = express.Router();
const axios = require('axios');

const data = require('../controllers/data');
const auth = require('../middlewares/auth');

// 공유 기능
router.get('/share', auth.checkToken, data.getShare);

// 실시간 크롤링 기능
router.get('/crawl', auth.checkToken, data.getCrawl);

module.exports = router;