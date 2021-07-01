let userModel = require('../models/users');
const secret = require('../config/secretKey');
const crypto = require('crypto');
const jwt = require('../modules/jwt');


const users = {
    signUp: async (req, res) => {
        let {email, password, name, nickName, profileUrl, birthday, gender, phoneNum} = req.body;

        // var img='';
        // if(req.file !== undefined)
        //     img = req.file.location;

        if (!email) return res.json({success: false, code: 2001, message: "이메일을 입력해 주세요."});
        if (email && email.length > 30) return res.json({
            success: false,
            code: 2002,
            message: "이메일은 30자리 미만으로 입력해주세요."
        });
        const regexEmail = /^[0-9a-zA-Z]([-_.]?[0-9a-zA-Z])*@[0-9a-zA-Z]([-_.]?[0-9a-zA-Z])*.[a-zA-Z]{2,3}$/i;
        if (email && !regexEmail.test(email)) return res.json({
            success: false,
            code: 2003,
            message: "올바르지 않은 이메일 형식입니다."
        });
        if (!password) return res.json({success: false, code: 2004, message: "비밀번호를 입력해 주세요."});
        const regexPwd = /^(?=.*\d)(?=.*[a-zA-Z])[0-9a-zA-Z]{6,20}$/;
        // if (password.length < 6 || password.length > 20) return res.json({
        if (!regexPwd.test(password)) return res.json({
            success: false,
            code: 2005,
            message: "비밀번호는 6~20자리의 영문 숫자조합이어야 합니다."
        });
        if (!name) return res.json({success: false, code: 2006, message: "이름을 입력해 주세요."});
        if (!nickName) return res.json({success: false, code: 2007, message: "닉네임을 입력해 주세요."});
        if (!profileUrl) profileUrl = 'default image';
        if (!birthday) return res.json({success: false, code: 2008, message: "생일을 입력해 주세요."});
        if (!gender) return res.json({success: false, code: 2009, message: "성별을 입력해 주세요.(M/W)"});
        if (!phoneNum) return res.json({success: false, code: 2010, message: "전화번호를 입력해주세요."});
        const regexPhoneNum = /^01(?:0|1|[6-9])(?:\d{3}|\d{4})\d{4}$/;
        if (phoneNum && !regexPhoneNum.test(phoneNum)) return res.json({
            success: false,
            code: 2011,
            message: "전화번호 형식이 올바르지 않습니다. (ex: 01012341234)"
        });

        try {
            //id 중복 확인
            const emailRow = await userModel.userEmailCheck(email);
            if (emailRow.length > 0) {
                return res.json({success: false, code: 3001, message: "중복된 이메일입니다"});
            }
            const phoneNumRow = await userModel.userPhoneNumCheck(phoneNum);
            if (phoneNumRow.length > 0) {
                return res.json({success: false, code: 3002, message: "중복된 전화번호입니다"});
            }

            // 비밀번호 암호화        
            const hashedPassword = await crypto.createHash('sha512').update(password).digest('hex');

            // 회원 가입
            const insertUserRows = await userModel.signUp(email, hashedPassword, name, nickName, profileUrl, birthday, gender, phoneNum);
            const [userInfoRows] = await userModel.selectUserInfoByEmail(email);

            // 회원 가입 성공
            return res.json({success: true, code: 1000, message: "회원가입 성공", result: {userIdx: userInfoRows[0].idx}});
        } catch (err) {
            console.log(error);
            return res.status(4000).send(`Error: ${err.message}`);
        }
    },
    signIn: async (req, res) => {
        const {email, password} = req.body;

        if (!email) return res.json({success: false, code: 2001, message: "이메일을 입력해 주세요."});
        if (!password) return res.json({success: false, code: 2004, message: "비밀번호를 입력해 주세요."});

        try {
            // 이메일 존재 확인
            const emailRows = await userModel.userEmailCheck(email);
            if (emailRows.length == 0) {
                return res.json({success: false, code: 3004, message: "존재하지 않는 이메일입니다"});
            }

            // 비밀번호 일치 확인
            const hashedPassword = await crypto
                .createHash("sha512")
                .update(password)
                .digest("hex");

            if (emailRows[0].password !== hashedPassword) {
                return res.json({success: false, code: 3005, message: "비밀번호가 일치하지 않습니다."});
            }

            // 계정 상태 확인
            if (emailRows[0].status === "I") {
                return res.json({success: false, code: 3006, message: "비활성화 계정입니다. 활성화를 진행하시겠습니까?"});
            }
            if (emailRows[0].status === "D") {
                return res.json({success: false, code: 3007, message: "탈퇴된 계정입니다. 재가입을 진행하시겠습니까?"});
            }

            // 로그인 여부 check
            userIdx = emailRows[0].idx;
            const checkJWT = await userModel.checkJWT(userIdx);
            if (checkJWT.length > 0) {
                return res.json({success: false, code: 3008, message: "이미 로그인된 계정입니다."});
            }

            // 로그인 (refreshToken이 아닌 accessToken만 사용)
            const {token, _} = await jwt.sign(userIdx);

            // token db에 넣기
            const tokenResult = await userModel.insertToken(userIdx, token);

            // 로그인 성공
            return res.json({
                success: true, code: 1000, message: "로그인 성공",
                result: {
                    userIdx: userIdx,
                    accessToken: token
                }
            });

        } catch (err) {
            console.log(error);
            return res.status(4000).send(`Error: ${err.message}`);
        }
    },
    authSendEmail: async (req, res) => {
        /*
        Body : snedEmail
        */
        const authNum = Math.floor((Math.random() * (999999 - 100000 + 1)) + 100000);

        const {email} = req.body;

        if (!email) return res.json({success: false, code: 2001, message: "이메일을 입력해 주세요."});
        if (email && email.length > 30) return res.json({
            success: false,
            code: 2002,
            message: "이메일은 30자리 미만으로 입력해주세요."
        });
        const regexEmail = /^[0-9a-zA-Z]([-_.]?[0-9a-zA-Z])*@[0-9a-zA-Z]([-_.]?[0-9a-zA-Z])*.[a-zA-Z]{2,3}$/i;
        if (email && !regexEmail.test(email)) return res.json({
            success: false,
            code: 2003,
            message: "올바르지 않은 이메일 형식입니다."
        });

        // TODO 이메일을 가지고 있는 유저 있는지 확인

        const mailOptions = {
            from: "wdh1121@naver.com",
            to: sendEmail,
            subject: "[파인드맵] 인증 관련 이메일 입니다.",
            text: `[인증번호] ${authNum}`
        };

        const result = smtpTransport.sendMail(mailOptions, (error, responses) => {
            if (error) {
                console.log(error);
                smtpTransport.close();
                return res.status(4000).send(`Error: ${err.message}`);
            } else {
                smtpTransport.close();
                // 캐시 데이터 저장
                ncache.set(sendEmail, authNum, 600);

                return res.send(response(baseResponse.USER_EMAIL_SEND_SUCCESS, {"authNumber": authNum}));
            }
        });
    },
    emailVerify: async (req, res) => {
        const {email, verifyCode} = req.body;

        if (!email) return res.json({success: false, code: 2001, message: "이메일을 입력해 주세요."});
        if (email && email.length > 30) return res.json({
            success: false,
            code: 2002,
            message: "이메일은 30자리 미만으로 입력해주세요."
        });
        const regexEmail = /^[0-9a-zA-Z]([-_.]?[0-9a-zA-Z])*@[0-9a-zA-Z]([-_.]?[0-9a-zA-Z])*.[a-zA-Z]{2,3}$/i;
        if (email && !regexEmail.test(email)) return res.json({
            success: false,
            code: 2003,
            message: "올바르지 않은 이메일 형식입니다."
        });

        if (!verifyCode) return res.json({success: false, code: 2015, message: "인증번호를 입력해 주세요."});
        if (verifyCode >= 100000000) return res.json({success: false, code: 2016, message: "인증번호의 길이가 올바르지 않습니다."});

        const CacheData = ncache.get(email);

        if (!CacheData) return res.json({success: false, code: 2017, message: "인증번호가 일치하지 않습니다."});
        if (CacheData != verifyCode) return res.json({success: false, code: 2018, message: "인증번호가 일치하지 않습니다."});

        //const emailVerifyResponse = await userService.postEmailVerify(email);

        // 이메일 유저 정보 확인
        /*
        const emailRows = await userModel.userEmailCheck(email);

        if (emailRows.length != 0){ // 이메일로 가입한 유저 정보가 있다면
            userIdx = emailRows[0].idx;

            // 뱃지가 없다면 생성, 있다면 에러 response
            const verifyemailRows = await userProvider.emailVerifyCheck(userIdx);
            if (verifyemailRows[0] != null) { //배지가 없다면 배지 생성
                return errResponse(baseResponse.ALREADY_AUTH_EMAIL); //이미 인증된 이메일입니다.
            } else {
                const userBadgeResult = await userDao.insertUserEmailBadge(connection, userIdx);
            }
        } else { // 이메일로 가입한 유저 정보가 없다면
            const userIdResult = await userDao.insertOnlyEmailUser(connection, email); //회원가입
            const emailRows = await userProvider.emailCheck(email);
            userIdx = emailRows[0].idx;

            // 뱃지가 없다면 생성, 있다면 에러 response
            const verifyemailRows = await userProvider.emailVerifyCheck(userIdx);
            if (verifyemailRows[0] != null) { //배지가 없다면 배지 생성, 회원가입
                return errResponse(baseResponse.ALREADY_AUTH_EMAIL); //이미 인증된 이메일입니다.
            } else {
                const userBadgeResult = await userDao.insertUserEmailBadge(connection, userIdx);
            }
        }
        */
        return res.json({success: false, code: 1000, message: "이메일 인증에 성공했습니다."});

    },
    logout: async (req, res) => {
        const userIdx = req.verifiedToken.userIdx;

        const checkJWT = await userModel.checkJWT(userIdx);
        if (checkJWT.length < 1) return res.json({success: false, code: 3009, message: "로그인되어 있지 않습니다."});
        if (token != checkJWT[0].jwt) return res.json({success: false, code: 3010, message: "토큰 검증 실패"});

        try {
            const deleteJWTResult = await userModel.deleteJWT(userIdx);
            return res.json({success: false, code: 1000, message: "로그아웃 성공"});
        } catch (err) {
            console.log(error);
            return res.status(4000).send(`Error: ${err.message}`);
        }
    },
    withdraw: async (req, res) => {
        const userIdx = req.params.userIdx;
        const token = req.headers['token'];

        if (!userIdx) return res.json({success: false, code: 2020, message: "userIdx를 입력해주세요."});
        if (!token) return res.json({success: false, code: 2020, message: "token을 입력해주세요."});

        const checkJWT = await userModel.checkJWT(userIdx);
        if (checkJWT.length < 1 || token != checkJWT[0].jwt) res.json({success: false, code: 2021, message: "userIdx가 일치하지 않습니다."});

        try {
            const deleteUserResult = await userModel.secession(userIdx);
            const deleteJWTResult = await userModel.deleteJWT(userIdx);
            return res.json({success: false, code: 1000, message: "회원 탈퇴 성공", result: {"userIdx": userIdx});
        } catch (err) {
            console.log(error);
            return res.status(4000).send(`Error: ${err.message}`);
        }
    },
    job: async (req, res) => { // 회원가입 정보 입력

        const userIdx = req.params.userIdx;
        let {job} = req.body;

        if (!job) return res.json({success: false, code: 2030, message: "신분을 입력해주세요."});

        try {
            const editUserResult = await userModel.updateUserJob(job);
            return res.json({success: false, code: 1000, message: "신분 선택 성공"})";
        } catch (err) {
            console.log(error);
            return res.status(4000).send(`Error: ${err.message}`);
        }
    };
}

module.exports = users;