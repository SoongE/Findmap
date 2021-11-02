const express = require('express');
const router = express.Router();
const axios = require('axios');

const recommend = require('../controllers/recommend');
const auth = require('../middlewares/auth');

// test
router.get('/test', auth.checkToken, recommend.getTest);

// 피드추천
router.get('/feeds', auth.checkToken, recommend.getRecommendFeeds);

// 추천검색어
router.get('/initSearchTerm', auth.checkToken, recommend.getInitSearchTerm);

// 연관검색어
router.get('/relatedSearchTerm', auth.checkToken, recommend.getRelatedSearchTerm);

// 인터넷 검색 (취향 정렬)
router.get('/search', auth.checkToken, recommend.getRecommendSearch);

// 검색어 categorize 
router.get('/categorize-word', auth.checkToken, recommend.getRecommendCategorizeWord);


module.exports = router;