var express = require('express');
var router = express.Router();

const scrap = require('../controllers/scrap');
const auth = require('../middlewares/auth');
//const upload = require('../../modules/multer');

// 스크랩 등록
router.post('/', auth.checkToken, scrap.postScrap); //flask

// 스크랩 전체 보기
router.get("/", auth.checkToken, scrap.getScrap);

// 스크랩 자세히 보기
router.get("/:scrapIdx/detail", auth.checkToken, scrap.getScrapDetail);

// 스크랩 폴더별 보기
// 스크랩 카테고리별 보기
// 스크랩 날짜별 보기

// 스크랩 코멘트 수정
router.patch('/:scrapIdx/comment', auth.checkToken, scrap.patchScrapComment);

// 스크랩 카테고리 수정
router.patch('/:scrapIdx/category', auth.checkToken, scrap.patchScrapCategory);

// 스크랩 폴더 수정
router.patch('/:scrapIdx/folder', auth.checkToken, scrap.patchScrapFolder);

// 스크랩 피드 수정
router.patch('/:scrapIdx/feed', auth.checkToken, scrap.patchScrapFeed);

// 스크랩 삭제
router.patch('/:scrapIdx/delete', auth.checkToken, scrap.deleteScrap);

module.exports = router;
