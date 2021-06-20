var express = require('express');
var router = express.Router();

const search = require('../controllers/seach');
const authUtil = require('../middlewares/auth').checkToken;
//const upload = require('../../modules/multer');

/*
// 검색 결과 조회
router.get('/search', search.getSearch);

// 실시간 검색어
router.get('/hot-search',search.getHotSearch);

// 추천 검색어 조회
router.post('/follow', search.follow);

// 검색하기 
router.post('/app/seach',search.postUserSearch);

// 검색 기록 조회 
router.get('/app/users/:userIdx/search/log',search.getUserSearch);

// 검색 기록 삭제
router.patch('/app/users/:userIdx/search/log',search.patchUserSearch);
*/

module.exports = router;
