var express = require('express');
var router = express.Router();

const scrap = require('../controllers/scrap');
const auth = require('../middlewares/auth');
//const upload = require('../../modules/multer');

// 스크랩 등록
router.post('/', auth.checkToken, scrap.postScrap); //flask

// 스크랩 전체 보기
router.get("/", auth.checkToken, scrap.getScrap);

// 스크랩 폴더별 보기
router.get("/by-folder", auth.checkToken, scrap.getScrapByFolder);

// 스크랩 카테고리별 보기
router.get("/by-category", auth.checkToken, scrap.getScrapByCategory);

// 스크랩 날짜별 보기
router.get("/by-date", auth.checkToken, scrap.getScrapByDate);

// 스크랩 자세히 보기
router.get("/:scrapIdx/detail", auth.checkToken, scrap.getScrapDetail);

// 스크랩 선택 수정
router.patch('/:scrapIdx', auth.checkToken, scrap.patchScrap);

// 스크랩 제목 수정
router.patch('/:scrapIdx/title', auth.checkToken, scrap.patchScrapTitle);

// 스크랩 줄거리 수정
router.patch('/:scrapIdx/summary', auth.checkToken, scrap.patchScrapSummary);

// 스크랩 코멘트 수정
router.patch('/:scrapIdx/comment', auth.checkToken, scrap.patchScrapComment);

// 스크랩 폴더 수정
router.patch('/:scrapIdx/folder', auth.checkToken, scrap.patchScrapFolder);

// 스크랩 피드 올리기
router.patch('/:scrapIdx/feed-upload', auth.checkToken, scrap.patchScrapFeedUp);

// 스크랩 피드 내리기
router.patch('/:scrapIdx/feed-down', auth.checkToken, scrap.patchScrapFeedDown);

// 스크랩 삭제
router.patch('/:scrapIdx/delete', auth.checkToken, scrap.deleteScrap);

module.exports = router;

