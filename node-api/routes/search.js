var express = require('express');
var router = express.Router();

const search = require('../controllers/search');
const auth = require('../middlewares/auth');

// 인터넷 검색 (검색 기록 o)
router.get('/', auth.checkToken, search.getSearchInternet);

// 피드 게시글 검색 (검색 기록 o)
router.get('/feed', auth.checkToken, search.getSearchFeed);

// 유저 검색
router.get('/user', auth.checkToken, search.getSearchUser);

// 검색 기록 조회 
router.get('/log', auth.checkToken, search.getSearchLog);

// 검색 기록 삭제
router.patch('/log/delete', auth.checkToken, search.deleteSearchLog);

// 실시간 검색어 등록
router.post('/hot',search.postHotSearchWord);

// 실시간 검색어 조회
router.get('/hot',search.getHotSearchWord);

// 추천 검색어 조회
router.get('/recommendation-word',auth.checkToken, search.getRecommendWord);

module.exports = router;