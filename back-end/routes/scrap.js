var express = require('express');
var router = express.Router();

const scrap = require('../controllers/scrap');
const auth = require('../middlewares/auth').checkToken;
//const upload = require('../../modules/multer');

/*
// 스크랩 등록 API (검색 후 버튼으로 등록, 사용자가 직접 글을 쓰는 기능은 없음.)
router.post('/article', scrap.postArticle);

// 스크랩 폴더 수정
router.patch('/folder/:folderIdx',scrap.patchFolder);

// 스크랩 폴더 이름
router.patch('/folder/:folderIdx',scrap.patchFolder);

// (폴더형식) 스크랩 조회
router.get('/folder',scrap.getFolder);

// 스크랩 삭제
router.patch('/articles/:articleIdx',scrap.patchScrap);

// 게시글 공유
router.get('/articles/:articleIdx/share',scrap.shareScrap);
*/

module.exports = router;
