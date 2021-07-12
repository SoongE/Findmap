var express = require('express');
var router = express.Router();

const follow = require('../controllers/follow');
const auth = require('../middlewares/auth');
//const upload = require('../../modules/multer');

/*
// 팔로우 등록/취소
router.post('/follow', auth.checkToken, follow.postFollow);

// 팔로우 목록 조회
router.get('/follow', auth.checkToken, follow.getfollow);

// 팔로우 게시글 조회
router.get('/following/article', auth.checkToken, follow.followingArticle);
*/

module.exports = router;