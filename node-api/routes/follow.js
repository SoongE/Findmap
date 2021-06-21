var express = require('express');
var router = express.Router();

const follow = require('../controllers/follow');
const auth = require('../middlewares/auth').checkToken;
//const upload = require('../../modules/multer');

/*
// 팔로우 등록/취소
router.post('/follow', auth,follow.postFollow);

// 팔로우 목록 조회
router.get('/follow', auth, follow.getfollow);

// 팔로우 게시글 조회
router.get('/following/article', auth, follow.followingArticle);
*/

module.exports = router;