const jwt = require('../modules/jwt');
const TOKEN_EXPIRED = -3;
const TOKEN_INVALID = -2;

const authUtil = {
    checkToken: async (req, res, next) => {
        var token = req.headers.token;
        // 토큰 없음
        if (!token)
            return res.json({isSuccess: false, code: 600, message: "토큰을 입력해주세요."});
        // decode
        const user = await jwt.verify(token);
        // 유효기간 만료
        if (user === TOKEN_EXPIRED)
            return res.json({isSuccess: false, code: 601, message: "유효기간이 만료"});
        // 유효하지 않는 토큰
        if (user === TOKEN_INVALID)
            return res.json({isSuccess: false, code: 602, message: "유효하지 않은 토큰"});
        if (user.idx === undefined)
            return res.json({isSuccess: false, code: 603, message: "유효하지 않은 토큰"});
        req.idx = user.idx;
        next();
    }
}

module.exports = authUtil;