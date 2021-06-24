let userModel = require('../models/users');
const secret = require('../config/secretKey');
const crypto = require('crypto');
const jwt = require('../modules/jwt');


const users = {
    signUp: async (req, res) => {
        let { id, password, name, nickName, profileUrl, birthday, gender, email, phoneNum } = req.body;

        // var img='';
        // if(req.file !== undefined)
        //     img = req.file.location;

        if (!id) return res.json({success: false, code: 300, message: "id를 입력해 주세요"});
        if (!password) return res.json({success: false, code: 301, message: "password를 입력해 주세요"});
        if (!name) return res.json({success: false, code: 302, message: "name을 입력해 주세요"});
        if (!nickName) return res.json({success: false, code: 303, message: "nickName을 입력해 주세요"});
        if (!profileUrl) profileUrl = 'default image';
        if (!birthday) return res.json({success: false, code: 304, message: "생일을 입력해 주세요"});
        if (!gender) return res.json({success: false, code: 305, message: "성별을 입력해 주세요"});
        if (!phoneNum && !email) return res.json({success: false, code: 306, message: "email과 phoneNum 중 하나는 입력해주세요"});
        if (email && email.length > 30) return res.json({success: false, code: 307,message: "이메일은 30자리 미만으로 입력해주세요"});
        const regexEmail = /^[0-9a-zA-Z]([-_.]?[0-9a-zA-Z])*@[0-9a-zA-Z]([-_.]?[0-9a-zA-Z])*.[a-zA-Z]{2,3}$/i;
        if (email && !regexEmail.test(email)) return res.json({success: false, code: 308, message: "올바르지 않은 email 형식입니다"});
        const regexPwd = /^(?=.*\d)(?=.*[a-zA-Z])[0-9a-zA-Z]{6,20}$/;
        // if (password.length < 6 || password.length > 20) return res.json({
        if (!regexPwd.test(password)) return res.json({success: false,code: 309,message: "비밀번호는 6~20자리의 영문 숫자조합이어야 합니다."});
        const regexPhoneNum = /^01(?:0|1|[6-9])(?:\d{3}|\d{4})\d{4}$/;
        if (phoneNum && !regexPhoneNum.test(phoneNum)) return res.json({success: false,code: 310,message: "phoneNum 형식이 맞지 않습니다 (ex: 01012341234)"});
        
        try {
            //id 중복 확인
            const idRow = await userModel.userIdCheck(id);
            if (idRow.length > 0) { return res.json({success: false,code: 401,message: "중복된 id입니다"});}
            const emailRow = await userModel.userEmailCheck(email);
            if (emailRow.length > 0) { return res.json({success: false,code: 402,message: "중복된 이메일입니다"});}
            const phoneNumRow = await userModel.userPhoneNumCheck(phoneNum);
            if (phoneNumRow.length > 0) { return res.json({success: false,code: 403,message: "중복된 전화번호입니다"});}

            // 비밀번호 암호화        
            const hashedPassword = await crypto.createHash('sha512').update(password).digest('hex');

            // 회원 가입
            const insertUserRows = await userModel.signUp(id, hashedPassword, name, nickName, profileUrl, birthday, gender, email, phoneNum);
            const [userInfoRows] = await userModel.selectUserInfoById(id);

            // 회원 가입 성공
            return res.json({success: true, code: 200, message: "회원가입 성공", result: {userIdx: userInfoRows[0].idx}});
        } catch (err) {
            console.log(error);
            return res.status(500).send(`Error: ${err.message}`);
        }
    },
    signIn : async (req, res) => {
        const { email, password } = req.body;

        if (!email) return res.json({success: false, code: 300, message: "email을 입력해 주세요"});
        if (!password) return res.json({success: false, code: 301, message: "password를 입력해 주세요"});
    
        try {
            // 이메일 존재 확인
            const emailRows = await userModel.userEmailCheck(email);
            if (emailRows.length == 0) { return res.json({success: false,code: 403,message: "존재하지 않는 이메일입니다"});}

            // 비밀번호 일치 확인
            const hashedPassword = await crypto
                .createHash("sha512")
                .update(password)
                .digest("hex");
            
            if (emailRows[0].password !== hashedPassword) { return res.json({success: false,code: 311,message: "비밀번호가 일치하지 않습니다."});}

            // 계정 상태 확인
            if (emailRows[0].status === "I") { return res.json({success: false,code: 404,message: "비활성화 계정입니다. 활성화를 진행하시겠습니까?"});}
            if (emailRows[0].status === "D") { return res.json({success: false,code: 405,message: "탈퇴된 계정입니다. 재가입을 진행하시겠습니까?"});}

            // 로그인 여부 check
            // userIdx = emailRows[0].idx;
            // const checkJWT = await userModel.checkJWT(userIdx);
            // if (checkJWT.length > 0) { return res.json({success: false,code: 406,message: "이미 로그인된 계정입니다."});}

            // 로그인 (refreshToken이 아닌 accessToken만 사용)
            const {token, _} = await jwt.sign(userIdx);

            // token db에 넣기
            const tokenResult = await userModel.insertToken(userIdx, token);

            // 로그인 성공
            return res.json({success: true, code: 200, message: "로그인 성공", 
            result: {
                userIdx: userIdx,
                accessToken: token
            }});

        } catch (err) {
            console.log(error);
            return res.status(500).send(`Error: ${err.message}`);
        }
    },
}

module.exports = users;