var express = require('express');
var router = express.Router();

const search = require('../controllers/seach');
const auth = require('../middlewares/auth');
//const upload = require('../../modules/multer');

/*
// 검색 결과 조회
router.get('/search', search.getSearch);

// 실시간 검색어
router.get('/hot-search',search.getHotSearch);

// 추천 검색어 조회
router.post('/follow',auth.checkToken, search.follow);

// 검색하기 
router.post('/seach',auth.checkToken, search.postUserSearch);

// 검색 기록 조회 
router.get('/log',auth.checkToken, search.getUserSearch);

// 검색 기록 삭제
router.patch('/log/status',auth.checkToken, search.deleteUserSearch);
*/

module.exports = router;
