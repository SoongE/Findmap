var express = require('express');
var router = express.Router();

const follow = require('../controllers/follow');
const auth = require('../middlewares/auth');

// 팔로우 등록/취소
router.patch('/', auth.checkToken, follow.patchFollow);

// 팔로워 목록 조회
router.get('/follower-list', auth.checkToken, follow.getFollowerList);

// 팔로잉 목록 조회
router.get('/following-list', auth.checkToken, follow.getFollowingList);

module.exports = router;