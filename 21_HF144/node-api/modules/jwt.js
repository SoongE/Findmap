const randToken = require('rand-token');
const jwt = require('jsonwebtoken');
const jwtscret = require('../config/secretKey').jwtsecret;
const options = require('../config/secretKey').options;
const TOKEN_EXPIRED = -3;
const TOKEN_INVALID = -2;

module.exports = {
    sign: async (userIdx) => {
        const payload = {
            userIdx: userIdx
        };
        const result = {
            //sign메소드를 통해 access token 발급
            token: jwt.sign(payload, jwtscret, options),
            refreshToken: randToken.uid(256)
        };
        return result;
    },
    verify: async (token) => {
        let decoded;
        try {
            decoded = jwt.verify(token, jwtscret);
        } catch (err) {
            if (err.message === 'jwt expired') {
                console.log('expired token');
                return TOKEN_EXPIRED;
            } else if (err.message === 'invalid token') {
                console.log('invalid token');
                console.log(TOKEN_INVALID);
                return TOKEN_INVALID;
            } else {
                console.log("invalid token");
                return TOKEN_INVALID;
            }
        }
        return decoded;
    },
    refresh: async (refreshToken) => {
        try {
            const result = jwt.verify(refreshToken, secretKey);
            if (result.userIdx === undefined) {
                return TOKEN_INVALID;
            }
            const user = await UserModel.getUserByIdx(result.userIdx);
            if (refreshToken !== user[0].refreshToken) {
                console.log('invalid refresh token');
                return TOKEN_INVALID;
            }
            const payload = {
                userIdx: user[0].userIdx,
                name: user[0].name
            };
            const dto = {
                token: jwt.sign(payload, secretKey, options),
                refreshToken: jwt.sign(payload, secretKey, refreshOptions)
            };
            await UserModel.updateRefreshToken(payload.userIdx, dto.refreshToken);
            return dto;
        } catch (err) {
            console.log('jwt.js ERROR : ', err);
            throw err;
        }
    }
}