var express = require('express');
var router = express.Router();

const feed = require('../controllers/feeds');
const auth = require('../middlewares/auth');

// 피드 저장 등록/취소
router.patch('/:scrapIdx/storage',auth.checkToken, feed.patchFeedStorage);

// 피드 하트 등록/취소
router.patch('/:scrapIdx/heart',auth.checkToken, feed.patchFeedHeart);

// 피드 방문 등록
router.patch('/:scrapIdx/history',auth.checkToken, feed.patchFeedHistory);

// 피드 프로필 조회
router.get('/profile',auth.checkToken, feed.getFeedProfile);

// 피드 조회
router.get('/',auth.checkToken, feed.getFeed);

// 추천 피드 가져오기
router.get('/recommendation',auth.checkToken, feed.getRecommendationFeed);

// 팔로잉 피드 가져오기
router.get('/following',auth.checkToken, feed.getFollowingFeed);

module.exports = router;
