var express = require('express');
var router = express.Router();

const folder = require('../controllers/folders');
const scrap = require('../controllers/scrap');
const auth = require('../middlewares/auth');
//const upload = require('../../modules/multer');

/*
// 폴더 등록
app.post("/", auth.checkToken, folder.insertFolder);

// 폴더 보기
app.get("/:folderIdx", auth.checkToken, folder.getFolder);

// 폴더 수정
app.patch("/:folderIdx", auth.checkToken, folder.patchFolder);

// 폴더 삭제
app.patch("/:folderIdx/status", auth.checkToken, folder.deleteFolder);

// 스크랩 등록
app.post("/:folderIdx/link", auth.checkToken, scrap.postScrap);

// 폴더 서치
app.get("/search", auth.checkToken, folder.searchFolder);
 */

module.exports = router;

