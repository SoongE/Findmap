let user = require('../models/user');
const secret_config = require('../config/secretKey');
const {logger} = require('../modules/winston');
const crypto = require('crypto');

/*
    test API
    마지막 수정일 : 2021.06.15
*/
exports.getTest = async (req, res) => {
    res.status(statusCode.OK).send(util.success(statusCode.OK, responseMsg.SUCCESS));
}

/*
    회원가입 API
    마지막 수정일 : 2021.06.17
*/
exports.signUp = async function (req, res) {
    let { id, password, name, nickName, profileUrl, birthday, gender, email, phoneNum } = req.body;

    // var img='';
    // if(req.file !== undefined)
    //     img = req.file.location;

    if (!id) return res.json({isSuccess: false, code: 300, message: "id를 입력해 주세요"});
    if (!password) return res.json({isSuccess: false, code: 301, message: "password를 입력해 주세요"});
    if (!name) return res.json({isSuccess: false, code: 302, message: "name을 입력해 주세요"});
    if (!nickName) return res.json({isSuccess: false, code: 303, message: "nickName을 입력해 주세요"});
    if (!profileUrl) profileUrl = 'default image';
    if (!birthday) return res.json({isSuccess: false, code: 304, message: "생일을 입력해 주세요"});
    if (!gender) return res.json({isSuccess: false, code: 305, message: "성별을 입력해 주세요"});
    if (!phoneNum && !email) return res.json({isSuccess: false, code: 306, message: "email과 phoneNum 중 하나는 입력해주세요"});
    if (email && email.length > 30) return res.json({isSuccess: false, code: 307,message: "이메일은 30자리 미만으로 입력해주세요"});
    const regexEmail = /^[0-9a-zA-Z]([-_.]?[0-9a-zA-Z])*@[0-9a-zA-Z]([-_.]?[0-9a-zA-Z])*.[a-zA-Z]{2,3}$/i;
    if (email && !regexEmail.test(email)) return res.json({isSuccess: false, code: 308, message: "올바르지 않은 email 형식입니다"});
    const regexPwd = /^(?=.*\d)(?=.*[a-zA-Z])[0-9a-zA-Z]{6,20}$/;
    // if (password.length < 6 || password.length > 20) return res.json({
    if (!regexPwd.test(password)) return res.json({isSuccess: false,code: 309,message: "비밀번호는 6~20자리의 영문 숫자조합이어야 합니다."});
    const regexPhoneNum = /^01(?:0|1|[6-9])(?:\d{3}|\d{4})\d{4}$/;
    if (phoneNum && !regexPhoneNum.test(phoneNum)) return res.json({isSuccess: false,code: 310,message: "phoneNum 형식이 맞지 않습니다 (ex: 01012341234)"});
    
    try {
        //id 중복 확인
        const idRow = await user.userIdCheck(id);
        if (idRow.length > 0) { return res.json({isSuccess: false,code: 401,message: "중복된 id입니다"});}
        const emailRow = await user.userEmailCheck(email);
        if (emailRow.length > 0) { return res.json({isSuccess: false,code: 402,message: "중복된 이메일입니다"});}
        const phoneNumRow = await user.userPhoneNumCheck(phoneNum);
        if (phoneNumRow.length > 0) { return res.json({isSuccess: false,code: 403,message: "중복된 전화번호입니다"});}

        // 비밀번호 암호화        
        const hashedPassword = await crypto.createHash('sha512').update(password).digest('hex');

        // 회원 가입
        const insertUserRows = await user.signUp(id, hashedPassword, name, nickName, profileUrl, birthday, gender, email, phoneNum);
        const [userInfoRows] = await user.selectUserInfoById(id);

        // 회원 가입 성공
        return res.json({result: {userIdx: userInfoRows[0].idx}, isSuccess: true, code: 200, message: "회원가입 성공"});
    } catch (err) {
        logger.error(`App - SignUp Controller error\n: ${err.message}`);
        return res.status(500).send(`Error: ${err.message}`);
    }
};