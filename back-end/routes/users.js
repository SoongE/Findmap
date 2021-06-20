var express = require('express');
var router = express.Router();

const user = require('../controllers/users');
const auth = require('../middlewares/auth');
//const upload = require('../modules/multer');

// 회원가입
router.post('/signup', user.signUp);

// 로그인
router.post('/signin',user.signIn);

/*
// 자동 로그인
router.post('/auto-login', user.autoLogin);

// 유저 정보 조회 API
router.get('/:userIdx/privacy', user.getUserPrivacy);

// 유저 정보 수정 API
router.patch('/:userIdx/privacy', user.patchUserPrivacy);

// 로그아웃 API
router.post('/auto-login', user.autoLogin);

// 탈퇴 API
router.post('/auto-login', user.autoLogin);

// 카카오 회원가입+로그인 API
router.post('/users/kakao', user.kakaoSignUp);

// 구글 회원가입+로그인 API
router.post('/users/google', user.googleSignUp);

// 이메일 인증, 검증
router.post('/auth/email',user.emailAuth);
*/

module.exports = router;
