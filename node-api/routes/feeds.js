var express = require('express');
var router = express.Router();

const feed = require('../controllers/feed');
const auth = require('../middlewares/auth').checkToken;
//const upload = require('../../modules/multer');

/*
// 피드 업로드 등록/취소
router.post('/feeds/:feedIdx/storage', feed.postStorage);

// 피드 좋아요 등록/취소
router.post('/feeds/:feedIdx/like', feed.postLike);

// 피드 삭제
router.patch('/feeds/:feedIdx', feed.deleteFeed);

// 피드 수정
router.patch('/feeds/:feedIdx', feed.patchFeed);
*/

module.exports = router;
