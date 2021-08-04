var express = require('express');
var router = express.Router();

const folder = require('../controllers/folders');
const auth = require('../middlewares/auth');

// 폴더 등록
router.post("/", auth.checkToken, folder.postFolder);

// 폴더 전체 보기
router.get("/", auth.checkToken, folder.getFolder);

// 폴더 상세 보기
router.get("/:folderIdx/detail", auth.checkToken, folder.getFolderDetail);

// 폴더 이름 수정
router.patch("/:folderIdx/name", auth.checkToken, folder.patchFolder);

// 폴더 삭제
router.patch("/:folderIdx/delete", auth.checkToken, folder.deleteFolder);

module.exports = router;

