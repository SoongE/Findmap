var express = require('express');
var router = express.Router();

const user = require('../controllers/users');
const auth = require('../middlewares/auth');

// 이메일 회원가입, 정보 입력 포함
router.post('/signup', user.signUp); 

// 이메일 회원가입, 정보 입력 미포함
router.post('/signup-simple', user.signUpSimple); 

// 이메일 로그인
router.post('/signin',user.signIn);

// 이메일 인증
router.post('/email-send', user.authSendEmail);

// 이메일 검증
router.get("/email-check", user.emailVerify);

// 로그아웃
router.get('/logout', auth.checkToken, user.logout);

// 탈퇴
router.patch('/withdraw', auth.checkToken, user.withdraw);

// 유저 정보 조회
router.get('/info', auth.checkToken, user.getUserInfo);

// 유저 정보 입력 (이름, 닉네임, 프로필사진, 생일, 성별)
router.patch('/info', auth.checkToken, user.patchUserInfo);

// 유저 정보 수정 (이름)
router.patch('/info-name', auth.checkToken, user.patchUserName);
// 유저 정보 수정 (닉네임)
router.patch('/info-nickName', auth.checkToken, user.patchUserNickName);
// 유저 정보 수정 (프로필사진)
router.patch('/info-profileUrl', auth.checkToken, user.patchUserProfileUrl);
// 유저 정보 수정 (생일)
router.patch('/info-birthday', auth.checkToken, user.patchUserBirthDay);
// 유저 정보 수정 (성별)
router.patch('/info-gender', auth.checkToken, user.patchUserGender);

// 관심분야 등록
router.post('/interest', auth.checkToken, user.postUserInterest);

// 관심분야 조회
router.get('/interest', auth.checkToken, user.getUserInterest);

// 관심분야 수정 (status Y라면 D, D이라면 Y)
router.patch('/interest', auth.checkToken, user.patchUserInterest);

/*
// 유저 이메일 찾기 API
router.get('/find-email', user.findEmail);

// 유저 비밀번호 찾기 API
router.post('/find-pw', user.findPW);

// 유저 이메일 변경 API
router.get('/update-email', user.updateEmail);

// 유저 비밀번호 변경 API
router.post('/update-pw', user.updatePW);
*/

/*
// 카카오 회원가입+로그인 API
router.post('/kakao', user.kakaoSignUp);

// 구글 회원가입+로그인 API
router.post('/google', user.googleSignUp);

// 애플 회원가입+로그인 API
router.post('/google', user.appleSignUp);
*/

module.exports = router;
