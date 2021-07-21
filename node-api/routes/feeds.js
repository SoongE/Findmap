var express = require('express');
var router = express.Router();

const feed = require('../controllers/feed');
const auth = require('../middlewares/auth');
//const upload = require('../../modules/multer');

/*
// 피드 업로드 등록/취소
router.post('/:feedIdx/storage',auth.checkToken, feed.postStorage);

// 피드 좋아요 등록/취소
router.post('/:feedIdx/like',auth.checkToken, feed.postLike);

// 피드 삭제
router.patch('/:feedIdx',auth.checkToken, feed.deleteFeed);

// 피드 수정
router.patch('/:feedIdx',auth.checkToken, feed.patchFeed);

// 피드 공유
router.get('/:feedIdx/share',auth.checkToken, scrap.shareFeed);
*/

module.exports = router;
