let userModel = require('../models/users');
const secret = require('../config/secretKey');
const crypto = require('crypto');
const jwt = require('../modules/jwt');

const { smtpTransport } = require("../config/email.js");
const nodeCache = require('node-cache');
const ncache = new nodeCache();

const regexEmail = /^[0-9a-zA-Z]([-_.]?[0-9a-zA-Z])*@[0-9a-zA-Z]([-_.]?[0-9a-zA-Z])*.[a-zA-Z]{2,3}$/i;
const regexPwd = /^(?=.*[A-Za-z])(?=.*\d)(?=.*[$@$!%*#?&])[A-Za-z\d$@$!%*#?&]{6,20}$/;
const regexBirthday = /^(19[0-9][0-9]|20\d{2})-(0[0-9]|1[0-2])-(0[1-9]|[1-2][0-9]|3[0-1])$/;
const regexName = /^([a-zA-Zㄱ-ㅎ|ㅏ-ㅣ|가-힣]).{1,10}$/;
const regexNickName = /^([a-zA-Z0-9ㄱ-ㅎ|ㅏ-ㅣ|가-힣]).{1,10}$/;
const regexSpc = /[~!@#$%^&*()_+|<>?:{}]/gi; // 특수문자
const regexUrl = /(http|https):\/\/(\w+:{0,1}\w*@)?(\S+)(:[0-9]+)?(\/|\/([\w#!:.?+=&%@!\-\/]))?/;
const regexGender = /^(W|M)/;

const users = {
    signUp: async (req, res) => {
        let {email, password, name, nickName, profileUrl, birthday, gender} = req.body;

        if (!email) return res.json({success: false, code: 2001, message: "이메일을 입력해 주세요."});
        if (!regexEmail.test(email)) return res.json({success: false,code: 2002,message: "올바르지 않은 이메일 형식입니다."});

        if (!password) return res.json({success: false, code: 2003, message: "비밀번호를 입력해 주세요."});
        if (!regexPwd.test(password)) return res.json({success: false,code: 2004,message: "비밀번호는 6자리~20자리로 최소 하나의 문자, 숫자, 특수 문자를 포함해야 합니다."});

        if (!name) return res.json({success: false, code: 2005, message: "name을 입력해 주세요."});
        if (!regexName.test(name)) return res.json({success: false, code: 2006, message: "name은 2~10자리의 한글,영문만 입력이 가능합니다."});
        if (name.search(/\s/) != -1 || regexSpc.test(name) == true ) return res.json({success: false, code: 2007, message: "name에는 공백 또는 특수문자를 입력할 수 없습니다."});

        if (!nickName) return res.json({success: false, code: 2008, message: "nickName을 입력해 주세요."});
        if (!regexNickName.test(nickName)) return res.json({success: false, code: 2009, message: "nickName은 2~10자리의 한글,영문,숫자로만 입력이 가능합니다."});
        if (regexSpc.test(nickName)) return res.json({success: false, code: 2010, message: "nickName에는 공백 또는 특수문자를 입력할 수 없습니다."});

        // if (!profileUrl) profileUrl = 'default image';
        // var img='';
        // if(req.file !== undefined)
        //     img = req.file.location;
        // if (!profileUrl) return res.json({success: false, code: 2011, message: "profileUrl을 입력해주세요."});

        if (profileUrl && !regexUrl.test(profileUrl)) return res.json({success: false, code: 2012, message: "profileUrl 형식이 올바르지 않습니다."});

        if (!birthday) return res.json({success: false, code: 2013, message: "birthday를 입력해 주세요."});
        if (!regexBirthday.test(birthday)) return res.json({success: false, code: 2014, message: "birthday 형식이 올바르지 않습니다.0000-00-00 형태로 입력해주세요."});

        if (!gender) return res.json({success: false, code: 2015, message: "gender를 입력해 주세요.(M/W)"});
        if (!regexGender.test(gender)) return res.json({success: false, code: 2016, message: "gender는 M 혹은 W의 형태로 입력해주세요."});

        const loginType = 1;

        try {
            //id 중복 확인
            const emailRow = await userModel.userEmailCheck(email);
            if (emailRow.length > 0) {
                return res.json({success: false, code: 3001, message: "중복된 이메일입니다"});
            }

            // 비밀번호 암호화        
            const hashedPassword = await crypto.createHash('sha512').update(password).digest('hex');

            // 회원 가입
            const result = await userModel.signUp(email, password, hashedPassword, name, nickName, profileUrl, birthday, gender, loginType);
            const [userInfoRow] = await userModel.selectUserInfoByEmail(email);

            // 회원 가입 성공
            return res.json({success: true, code: 1000, message: "회원가입 성공", result: {userIdx: userInfoRow[0].idx}});
        } catch (err) {
            console.log(error);
            return res.status(4000).send(`Error: ${err.message}`);
        }
    },
    signUpSimple: async (req, res) => {
        let {email, password} = req.body;

        if (!email) return res.json({success: false, code: 2001, message: "이메일을 입력해 주세요."});
        if (!regexEmail.test(email)) return res.json({success: false,code: 2002,message: "올바르지 않은 이메일 형식입니다."});

        if (!password) return res.json({success: false, code: 2003, message: "비밀번호를 입력해 주세요."});
        if (!regexPwd.test(password)) return res.json({success: false,code: 2004,message: "비밀번호는 6자리~20자리로 최소 하나의 문자, 숫자, 특수 문자를 포함해야 합니다."});

        const loginType = 2;

        try {
            //id 중복 확인
            const emailRow = await userModel.userEmailCheck(email);
            if (emailRow.length > 0) {
                return res.json({success: false, code: 3001, message: "중복된 이메일입니다"});
            }

            // 비밀번호 암호화        
            const hashedPassword = await crypto.createHash('sha512').update(password).digest('hex');

            // 회원 가입
            const result = await userModel.signUpSimple(email, password, hashedPassword, loginType);
            const [userInfoRow] = await userModel.selectUserInfoByEmail(email);

            // 회원 가입 성공
            return res.json({success: true, code: 1000, message: "간편 회원가입 성공", result: {userIdx: userInfoRow[0].idx}});
        } catch (err) {
            console.log(error);
            return res.status(4000).send(`Error: ${err.message}`);
        }
    },
    signIn: async (req, res) => {
        let {email, password} = req.body;

        if (!email) return res.json({success: false, code: 2001, message: "이메일을 입력해 주세요."});
        if (!password) return res.json({success: false, code: 2004, message: "비밀번호를 입력해 주세요."});

        try {
            // 이메일 존재 확인
            const emailRow = await userModel.userEmailCheck(email);
            if (emailRow.length == 0) {
                return res.json({success: false, code: 3002, message: "존재하지 않는 이메일입니다"});
            }
            // 비밀번호 일치 확인
            const hashedPassword = await crypto
                .createHash("sha512")
                .update(password)
                .digest("hex");

            if (emailRow[0].hashedPassword !== hashedPassword) {
                return res.json({success: false, code: 3003, message: "비밀번호가 일치하지 않습니다."});
            }

            // 계정 상태 확인
            if (emailRow[0].status === "N") {
                return res.json({success: false, code: 3004, message: "비활성화 계정입니다."});
            }
            if (emailRow[0].status === "D") {
                return res.json({success: false, code: 3005, message: "탈퇴된 계정입니다."});
            }

            // 로그인 여부 check
            userIdx = emailRow[0].idx;

            const checkJWT = await userModel.checkJWT(userIdx);

            if (checkJWT[0].length > 0) {
                return res.json({success: false, code: 3006, message: "이미 로그인된 계정입니다."});
            }

            const checkIsJWT = await userModel.checkIsJWT(userIdx);

            if (checkIsJWT[0].length < 1) { // 처음으로 로그인 함, token 발급 필요
                // 토큰 발급 (refreshToken이 아닌 accessToken만 사용)
                const {token, _} = await jwt.sign(userIdx);

                // token db에 넣기
                const result = await userModel.insertToken(userIdx, token);
                const [tokenResult] = await userModel.checkJWT(userIdx);

                // 로그인 성공
                return res.json({
                    success: true, code: 1000, message: "로그인 성공",
                    result: { 
                        "token": tokenResult[0].token, 
                        "userInfo":emailRow[0]
                    }
                });
            } else { // token 이미 존재, 존재하는 token으로 로그인
                // 로그인 성공
                const result = await userModel.reuseJWT(userIdx);
                const [tokenResult] = await userModel.checkJWT(userIdx);

                return res.json({
                    success: true, code: 1000, message: "로그인 성공",
                    result: { 
                        "token": tokenResult[0].token, 
                        "userInfo":emailRow[0]
                    }
                });
            }

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

        let {email} = req.body;

        if (!email) return res.json({success: false, code: 2001, message: "이메일을 입력해 주세요."});
        if (!regexEmail.test(email)) return res.json({success: false,code: 2002,message: "올바르지 않은 이메일 형식입니다."});

        // TODO 이메일을 가지고 있는 유저 있는지 확인

        const mailOptions = {
            from: "wdh1121@naver.com",
            to: email,
            subject: "[파인드맵] 인증 이메일 입니다.",
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
                ncache.set(email, authNum, 600);

                return res.json({success: true, code: 1000, message: "인증메일 전송 성공", result: {"authNumber": authNum}});
            }
        });
    },
    emailVerify: async (req, res) => {
        let {email, verifyCode} = req.body;

        if (!email) return res.json({success: false, code: 2001, message: "이메일을 입력해 주세요."});
        if (!regexEmail.test(email)) return res.json({success: false,code: 2002,message: "올바르지 않은 이메일 형식입니다."});

        if (!verifyCode) return res.json({success: false, code: 2020, message: "인증번호를 입력해 주세요."});
        if (verifyCode >= 100000000) return res.json({success: false, code: 2021, message: "인증번호의 길이가 올바르지 않습니다."});

        const CacheData = ncache.get(email);

        if (!CacheData) return res.json({success: false, code: 2022, message: "인증 캐시 데이터를 가져오지 못했습니다."});
        if (CacheData != verifyCode) return res.json({success: false, code: 2023, message: "인증번호가 일치하지 않습니다."});

        return res.json({success: false, code: 1000, message: "이메일 검증 성공"});

    },
    logout: async (req, res) => {
        const userIdx = req.decoded.userIdx;

        try {
            const checkJWT = await userModel.checkJWT(userIdx);
            if (checkJWT[0].length < 1) return res.json({success: false, code: 3007, message: "로그인되어 있지 않습니다."});
    
            const result = await userModel.deleteJWT(userIdx);
            return res.json({success: true, code: 1000, message: "로그아웃 성공", result: {"userIdx": userIdx}});
        } catch (err) {
            console.log(error);
            return res.status(4000).send(`Error: ${err.message}`);
        }
    },
    withdraw: async (req, res) => {
        const userIdx = req.decoded.userIdx;

        try {
            const checkJWT = await userModel.checkJWT(userIdx);
            if (checkJWT[0].length < 1) return res.json({success: false, code: 3007, message: "로그인되어 있지 않습니다."});

            const deleteUserResult = await userModel.withdraw(userIdx);
            const deleteJWTResult = await userModel.deleteJWT(userIdx);
            
            return res.json({success: false, code: 1000, message: "회원 탈퇴 성공", result: {"userIdx": userIdx}});
        } catch (err) {
            console.log(error);
            return res.status(4000).send(`Error: ${err.message}`);
        }
    },
    getUserInfo: async (req, res) => {
        const userIdx = req.decoded.userIdx;
        
        try {
            // 로그인 확인
            const checkJWT = await userModel.checkJWT(userIdx);
            if (checkJWT[0].length < 1) return res.json({success: false, code: 3007, message: "로그인되어 있지 않습니다."});
            
            const userInfoRow = await userModel.selectUserInfo(userIdx);
            return res.json({success: true, code: 1000, message: "유저 정보 조회 성공", result: userInfoRow[0]});
        } catch (err) {
            console.log(error);
            return res.status(4000).send(`Error: ${err.message}`);
        }
    },
    patchUserInfo: async (req, res) => {
        const userIdx = req.decoded.userIdx;

        let {name, nickName, profileUrl, birthday, gender} = req.body;
        
        if (!name) return res.json({success: false, code: 2005, message: "name을 입력해 주세요."});
        if (!regexName.test(name)) return res.json({success: false, code: 2006, message: "name은 2~10자리의 한글,영문만 입력이 가능합니다."});
        if (name.search(/\s/) != -1 || regexSpc.test(name) == true ) return res.json({success: false, code: 2007, message: "name에는 공백 또는 특수문자를 입력할 수 없습니다."});

        if (!nickName) return res.json({success: false, code: 2008, message: "nickName을 입력해 주세요."});
        if (!regexNickName.test(nickName)) return res.json({success: false, code: 2009, message: "nickName은 2~10자리의 한글,영문,숫자로만 입력이 가능합니다."});
        if (regexSpc.test(nickName)) return res.json({success: false, code: 2010, message: "nickName에는 공백 또는 특수문자를 입력할 수 없습니다."});

        // if (!profileUrl) profileUrl = 'default image';
        // var img='';
        // if(req.file !== undefined)
        //     img = req.file.location;
        // if (!profileUrl) return res.json({success: false, code: 2011, message: "profileUrl을 입력해주세요."});

        if (profileUrl && !regexUrl.test(profileUrl)) return res.json({success: false, code: 2012, message: "profileUrl 형식이 올바르지 않습니다."});

        if (!birthday) return res.json({success: false, code: 2013, message: "birthday를 입력해 주세요."});
        if (!regexBirthday.test(birthday)) return res.json({success: false, code: 2014, message: "birthday 형식이 올바르지 않습니다.0000-00-00 형태로 입력해주세요."});

        if (!gender) return res.json({success: false, code: 2015, message: "gender를 입력해 주세요.(M/W)"});
        if (!regexGender.test(gender)) return res.json({success: false, code: 2016, message: "gender는 M 혹은 W의 형태로 입력해주세요."});

        try {
            // 로그인 확인
            const checkJWT = await userModel.checkJWT(userIdx);
            if (checkJWT[0].length < 1) return res.json({success: false, code: 3007, message: "로그인되어 있지 않습니다."});

            const result = await userModel.updateUserInfo(userIdx, name, nickName, profileUrl, birthday, gender);
            const userInfoRow = await userModel.userIdxCheck(userIdx);

            return res.json({success: true, code: 1000, message: "유저 정보 수정 성공", result: userInfoRow[0]});
        } catch (err) {
            console.log(error);
            return res.status(4000).send(`Error: ${err.message}`);
        }
    },
    patchUserName: async (req, res) => {
        const userIdx = req.decoded.userIdx;

        let {name} = req.body;
        
        if (!name) return res.json({success: false, code: 2005, message: "name을 입력해 주세요."});
        if (!regexName.test(name)) return res.json({success: false, code: 2006, message: "name은 2~10자리의 한글,영문만 입력이 가능합니다."});
        if (name.search(/\s/) != -1 || regexSpc.test(name) == true ) return res.json({success: false, code: 2007, message: "name에는 공백 또는 특수문자를 입력할 수 없습니다."});
        
        try {
            // 로그인 확인
            const checkJWT = await userModel.checkJWT(userIdx);
            if (checkJWT[0].length < 1) return res.json({success: false, code: 3007, message: "로그인되어 있지 않습니다."});

            const result = await userModel.updateUserName(userIdx, name);
            const userInfoRow = await userModel.userIdxCheck(userIdx);

            return res.json({success: true, code: 1000, message: "유저 name 수정 성공", result: userInfoRow[0]});
        } catch (err) {
            console.log(error);
            return res.status(4000).send(`Error: ${err.message}`);
        }
    },
    patchUserNickName: async (req, res) => {
        const userIdx = req.decoded.userIdx;

        let {nickName} = req.body;

        if (!nickName) return res.json({success: false, code: 2008, message: "nickName을 입력해 주세요."});
        if (!regexNickName.test(nickName)) return res.json({success: false, code: 2009, message: "nickName은 2~10자리의 한글,영문,숫자로만 입력이 가능합니다."});
        if (regexSpc.test(nickName)) return res.json({success: false, code: 2010, message: "nickName에는 공백 또는 특수문자를 입력할 수 없습니다."});

        try {
            // 로그인 확인
            const checkJWT = await userModel.checkJWT(userIdx);
            if (checkJWT[0].length < 1) return res.json({success: false, code: 3007, message: "로그인되어 있지 않습니다."});

            const result = await userModel.updateUserNickName(userIdx, nickName);
            const userInfoRow = await userModel.userIdxCheck(userIdx);

            return res.json({success: true, code: 1000, message: "유저 nickName 수정 성공", result: userInfoRow[0]});
        } catch (err) {
            console.log(error);
            return res.status(4000).send(`Error: ${err.message}`);
        }
    },
    patchUserProfileUrl: async (req, res) => {
        const userIdx = req.decoded.userIdx;

        let {profileUrl} = req.body;
        
        if (!profileUrl) return res.json({success: false, code: 2011, message: "profileUrl을 입력해주세요."});
        if (profileUrl && !regexUrl.test(profileUrl)) return res.json({success: false, code: 2012, message: "profileUrl 형식이 올바르지 않습니다."});

        try {
            // 로그인 확인
            const checkJWT = await userModel.checkJWT(userIdx);
            if (checkJWT[0].length < 1) return res.json({success: false, code: 3007, message: "로그인되어 있지 않습니다."});

            const result = await userModel.updateUserProfileUrl(userIdx, profileUrl);
            const userInfoRow = await userModel.userIdxCheck(userIdx);

            return res.json({success: true, code: 1000, message: "유저 profileUrl 수정 성공", result: userInfoRow[0]});
        } catch (err) {
            console.log(error);
            return res.status(4000).send(`Error: ${err.message}`);
        }
    },
    patchUserBirthDay: async (req, res) => {
        const userIdx = req.decoded.userIdx;

        let {birthday} = req.body;
        
        if (!birthday) return res.json({success: false, code: 2013, message: "birthday를 입력해 주세요."});
        if (!regexBirthday.test(birthday)) return res.json({success: false, code: 2014, message: "birthday 형식이 올바르지 않습니다.0000-00-00 형태로 입력해주세요."});

        try {
            // 로그인 확인
            const checkJWT = await userModel.checkJWT(userIdx);
            if (checkJWT[0].length < 1) return res.json({success: false, code: 3007, message: "로그인되어 있지 않습니다."});

            const result = await userModel.updateUserBirthDay(userIdx, birthday);  
            const userInfoRow = await userModel.userIdxCheck(userIdx);

            return res.json({success: true, code: 1000, message: "유저 birthday 수정 성공", result: userInfoRow[0]});
        } catch (err) {
            console.log(error);
            return res.status(4000).send(`Error: ${err.message}`);
        }
    },
    patchUserGender: async (req, res) => {
        const userIdx = req.decoded.userIdx;

        let {gender} = req.body;
        
        if (!gender) return res.json({success: false, code: 2015, message: "gender를 입력해 주세요.(M/W)"});
        if (!regexGender.test(gender)) return res.json({success: false, code: 2016, message: "gender는 M 혹은 W의 형태로 입력해주세요."});

        try {
            // 로그인 확인
            const checkJWT = await userModel.checkJWT(userIdx);
            if (checkJWT[0].length < 1) return res.json({success: false, code: 3007, message: "로그인되어 있지 않습니다."});

            const result = await userModel.updateUserGender(userIdx, gender);
            const userInfoRow = await userModel.userIdxCheck(userIdx);

            return res.json({success: true, code: 1000, message: "유저 gender 수정 성공", result: userInfoRow[0]});
        } catch (err) {
            console.log(error);
            return res.status(4000).send(`Error: ${err.message}`);
        }
    },
    getUserInterest: async (req, res) => {
        const userIdx = req.decoded.userIdx;

        try {
            // 로그인 확인
            const checkJWT = await userModel.checkJWT(userIdx);
            if (checkJWT[0].length < 1) return res.json({success: false, code: 3007, message: "로그인되어 있지 않습니다."});

            const [userInterestRow] = await userModel.selectUserInterest(userIdx);

            if (userInterestRow[0] == undefined){
                return res.json({success: true, code: 3011, message: "유저 관심 카테고리가 존재하지 않습니다."});
            }

            return res.json({success: true, code: 1000, message: "유저 관심 카테고리 조회 성공", result: userInterestRow});
        } catch (err) {
            console.log(error);
            return res.status(4000).send(`Error: ${err.message}`);
        }
    },
    patchUserInterest: async (req, res) => { // 관심 카테고리 선택
        const userIdx = req.decoded.userIdx;
        let {categoryIdx} = req.body;

        if (!categoryIdx) return res.json({success: false, code: 2030, message: "관심 카테고리를 선택해주세요."});
        
        if (1<=categoryIdx && categoryIdx<=4) return res.json({success: false, code: 2030, message: "1~4는 상위 관심 카테고리를 나타냅니다. 5~36의 하위 관심 카테고리를 선택해주세요."});
        if (categoryIdx<1 || categoryIdx>36) return res.json({success: false, code: 2030, message: "선택할 수 있는 범위를 넘어섰습니다. 5~36의 숫자를 입력해주세요."});
        

        try {
            // 로그인 확인
            const checkJWT = await userModel.checkJWT(userIdx);
            if (checkJWT[0].length < 1) return res.json({success: false, code: 3007, message: "로그인되어 있지 않습니다."});

            const [checkUserInterest] = await userModel.checkUserInterest(userIdx, categoryIdx);

            if (checkUserInterest.length < 1) { //userInterest가 존재하지 않는다면

                const result = await userModel.postUserInterest(userIdx, categoryIdx);
                return res.json({success: true, code: 1000, message: "유저 관심 카테고리 추가 성공"});

            } else { //userInterest가 존재한다면

                if (checkUserInterest[0].status == 'Y'){
                    const result = await userModel.deleteUserInterest(userIdx, categoryIdx);
                    return res.json({success: true, code: 1000, message: "유저 관심 카테고리 삭제 성공"});
                } 
                if (checkUserInterest[0].status == 'D'){
                    const result = await userModel.reuseUserInterest(userIdx, categoryIdx);
                    return res.json({success: true, code: 1000, message: "유저 관심 카테고리 선택 성공"});
                }
            }

        } catch (err) {
            console.log(error);
            return res.status(4000).send(`Error: ${err.message}`);
        }
    }
}

module.exports = users;