var express = require('express');
var router = express.Router();

const scrap = require('../controllers/scrap');
const auth = require('../middlewares/auth');
//const upload = require('../../modules/multer');

/*
// 스크랩 등록
router.post('/', auth.checkToken, scrap.postScrap);

// 스크랩 전체 보기
app.get("/", auth.checkToken, scrap.getScrap);

// 스크랩 보기
app.get("/:scrapIdx", auth.checkToken, scrap.getScrapDetail);

// 스크랩 수정
router.patch('/:scrapIdx',scrap.patchScrap);

// 스크랩 삭제
router.patch('/:scrapIdx/status',scrap.deleteScrap);

// 스크랩 피드 등록
router.post('/scrapToFeed', scrap.postScrapToFeed);
 */

module.exports = router;

