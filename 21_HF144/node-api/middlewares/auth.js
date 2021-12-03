const jwt = require('../modules/jwt');
const TOKEN_EXPIRED = -3;
const TOKEN_INVALID = -2;

const authUtil = {
    checkToken: async (req, res, next) => {
        var token = req.headers.token;
        // 토큰 없음
        if (!token)
            return res.json({success: false, code: 5001, message: "토큰을 입력해 주세요."});
        // decode
        const user = await jwt.verify(token);
        // 유효기간 만료
        if (user === TOKEN_EXPIRED)
            return res.json({success: false, code: 5002, message: "토큰 유효기간이 만료되었습니다."});
        // 유효하지 않는 토큰
        if (user === TOKEN_INVALID)
            return res.json({success: false, code: 5003, message: "유효하지 않은 토큰입니다."});
        if (user.userIdx === undefined)
            return res.json({success: false, code: 5003, message: "유효하지 않은 토큰입니다."});
        req.decoded = user;
        next();
    }
}

module.exports = authUtil;