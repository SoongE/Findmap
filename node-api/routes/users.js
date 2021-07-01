var express = require('express');
var router = express.Router();

const user = require('../controllers/users');
const {auth} = require('../middlewares/auth');
//const upload = require('../modules/multer');

// 이메일 회원가입
router.post('/signup', user.signUp); //비밀번호 확인 추가

// 이메일 로그인
router.post('/signin',user.signIn);

// 이메일 인증
router.post('/email-send', user.authSendEmail);

// 이메일 검증
router.get("/email-check", user.emailVerify);

// 로그아웃
router.get('/logout', auth, user.logout);

// 탈퇴
router.patch('/withdraw', auth, user.withdraw);

/*
// 신분 선택
router.patch('/:userIdx/job', auth, user.job);
// 연령대 선택
router.patch('/:userIdx/age', auth, user.age);
// 관심분야 선택
router.patch('/:userIdx/interest', auth, user.interest);
 */

/*
// 유저 정보 조회 API
router.get('/:userIdx/privacy', user.getUserPrivacy);

// 유저 정보 수정 API
router.patch('/:userIdx/privacy', user.patchUserPrivacy);

// 카카오 회원가입+로그인 API
router.post('/users/kakao', user.kakaoSignUp);

// 구글 회원가입+로그인 API
router.post('/users/google', user.googleSignUp);
*/

module.exports = router;
