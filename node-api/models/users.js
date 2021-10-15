const pool = require('../modules/pool');
const db = require('../config/database');

const users = {
    userEmailCheck: async(email) => {
        const query = `SELECT * FROM UserTB WHERE email = ?`;
        const params = [email];
        try {
            const result = await pool.queryParam(query,params);
            return result;
        } catch (err) {
            console.log('emailCheck ERROR: ', err);
            throw err;
        }
    },
    userIdxCheck: async(userIdx) => {
        const query = `SELECT * FROM UserTB WHERE idx = ?`;
        const params = [userIdx];
        try {
            const result = await pool.queryParam(query,params);
            return result;
        } catch (err) {
            console.log('userIdxCheck ERROR: ', err);
            throw err;
        }
    },
    selectUserInfoByEmail: async(email) => {
        const query = `
            SELECT idx, name, email
            FROM UserTB
            WHERE email = ? and status = 'Y';`;
        const params = [email];
        try {
            const result = await pool.queryParam(query,params);
            return [result];
        } catch (err) {
            console.log('selectUserInfoById ERROR: ', err);
            throw err;
        }
    },
    selectUserInfo: async(userIdx) => {
        const query = `SELECT * FROM UserTB WHERE idx = ? and status = 'Y';`;
        const params = [userIdx];
        try {
            const result = await pool.queryParam(query,params);
            return [result];
        } catch (err) {
            console.log('유저 정보 조회 ERROR: ', err);
            throw err;
        }
    },
    signUp: async (email, password, hashedPassword, name, nickName, profileUrl, description, birthday, gender, loginType) => {
        const fields = 'email, password, hashedPassword, name, nickName, profileUrl, description, birthday, gender, loginType';
        const values = [email, password, hashedPassword, name, nickName, profileUrl, description, birthday, gender, loginType];
        const query = `INSERT INTO UserTB(${fields}) VALUES(?,?,?,?,?,?,?,?,?,?)`;
        try {
            const result = await pool.queryParamArr(query, values);
            return result;
        } catch (err) {
            console.log('signUp ERROR: ', err);
            throw err;
        }
    },
    signUpSimple: async (email, password, hashedPassword,loginType) => {
        const fields = 'email, password, hashedPassword,loginType';
        const values = [email, password, hashedPassword,loginType];
        const query = `INSERT INTO UserTB(${fields}) VALUES(?,?,?,?)`;
        try {
            const result = await pool.queryParamArr(query, values);
            return result;
        } catch (err) {
            console.log('signup ERROR: ', err);
            throw err;
        }
    },
    insertToken: async(userIdx, token) => {
        const fields = 'userIdx, token';
        const values = [userIdx, token];
        const query = `INSERT INTO TokenTB(${fields}) VALUES(?,?)`;
        try {
            const result = await pool.queryParamArr(query, values);
            return result;
        } catch (err) {
            console.log('insertToken ERROR: ', err);
            throw err;
        }
    },
    checkIsJWT: async(userIdx) => {
        const query = `SELECT * FROM TokenTB WHERE userIdx = ?;`;
        const params = [userIdx];
        try {
            const result = await pool.queryParam(query,params);
            return [result];
        } catch (err) {
            console.log('checkJWT ERROR: ', err);
            throw err;
        }
    },
    checkJWT: async(userIdx) => {
        const query = `SELECT * FROM TokenTB WHERE userIdx = ? and status = 'Y';`;
        const params = [userIdx];
        try {
            const result = await pool.queryParam(query,params);
            return [result];
        } catch (err) {
            console.log('checkJWT ERROR: ', err);
            throw err;
        }
    },
    reuseJWT: async(userIdx) => {
        const query = `UPDATE TokenTB SET status = 'Y' WHERE userIdx = ?;`;
        const params = [userIdx];
        try {
            const result = await pool.queryParam(query,params);
            return [result];
        } catch (err) {
            console.log('updateJWT ERROR: ', err);
            throw err;
        }
    },
    deleteJWT: async(userIdx) => {
        const query = `UPDATE TokenTB SET status = 'D' WHERE userIdx = ?;`;
        const params = [userIdx];
        try {
            const result = await pool.queryParam(query,params);
            return [result];
        } catch (err) {
            console.log('deleteJWT ERROR: ', err);
            throw err;
        }
    },
    withdraw: async(userIdx) => {
        const query = `UPDATE UserTB SET status = 'D' WHERE idx = ?;`;
        const params = [userIdx];
        try {
            const result = await pool.queryParam(query,params);
            return [result];
        } catch (err) {
            console.log('withdraw ERROR: ', err);
            throw err;
        }
    },
    updateUserInfo: async(userIdx, name, nickName, profileUrl, birthday, gender) => { 
        const query = `UPDATE UserTB SET name = ?, nickName = ?, profileUrl = ?, birthday = ?, gender = ? 
        WHERE idx = ? and status = 'Y';`
        const params = [name, nickName, profileUrl, birthday, gender, userIdx];
        try {
            const result = await pool.queryParam(query,params);
            return [result];
        } catch (err) {
            console.log('유저 info 수정 ERROR : ', err);
            throw err;
        }
    },
    updateUserName: async(userIdx, name) => {
        const query = `UPDATE UserTB SET name = ? WHERE idx = ? and status = 'Y';`
        const params = [name, userIdx];
        try {
            const result = await pool.queryParam(query,params);
            return [result];
        } catch (err) {
            console.log('유저 name 수정 ERROR : ', err);
            throw err;
        }
    },
    updateUserNickName: async(userIdx, nickName) => {
        const query = `UPDATE UserTB SET nickName = ? WHERE idx = ? and status = 'Y';`
        const params = [nickName, userIdx];
        try {
            const result = await pool.queryParam(query,params);
            return [result];
        } catch (err) {
            console.log('유저 nickName 수정 ERROR : ', err);
            throw err;
        }
    },
    updateUserProfileUrl: async(userIdx, profileUrl) => {
        const query = `UPDATE UserTB SET profileUrl = ? WHERE idx = ? and status = 'Y';`
        const params = [profileUrl, userIdx];
        try {
            const result = await pool.queryParam(query,params);
            return [result];
        } catch (err) {
            console.log('유저 profileUrl 수정 ERROR : ', err);
            throw err;
        }
    },
    updateUserBirthDay: async(userIdx, birthday) => {
        const query = `UPDATE UserTB SET birthday = ? WHERE idx = ? and status = 'Y';`
        const params = [birthday, userIdx];
        try {
            const result = await pool.queryParam(query,params);
            return [result];
        } catch (err) {
            console.log('유저 birthday 수정 ERROR : ', err);
            throw err;
        }
    },
    updateUserGender: async(userIdx, gender) => {
        const query = `UPDATE UserTB SET gender = ? WHERE idx = ? and status = 'Y';`
        const params = [gender, userIdx];
        try {
            const result = await pool.queryParam(query,params);
            return [result];
        } catch (err) {
            console.log('유저 gender 수정 ERROR : ', err);
            throw err;
        }
    },
    updateUserDescription: async(userIdx, description) => {
        const query = `UPDATE UserTB SET description = ? WHERE idx = ? and status = 'Y';`
        const params = [description, userIdx];
        try {
            const result = await pool.queryParam(query,params);
            return [result];
        } catch (err) {
            console.log('유저 description 수정 ERROR : ', err);
            throw err;
        }
    },
    checkUserInterest: async(userIdx, categoryIdx) => {
        const query = `SELECT * FROM UserInterestTB WHERE userIdx = ? and categoryIdx = ?;`
        const params = [userIdx, categoryIdx];
        try {
            const result = await pool.queryParam(query,params);
            return [result];
        } catch (err) {
            console.log('유저 interestIdx check ERROR: ', err);
            throw err;
        }
    },
    postUserInterest: async(userIdx, categoryIdx) => {
        const fields = 'userIdx, categoryIdx';
        const values = [userIdx, categoryIdx];
        const query = `INSERT INTO UserInterestTB(${fields}) VALUES(?,?)`;
        try {
            const result = await pool.queryParamArr(query, values);
            return result;
        } catch (err) {
            console.log('UserInterest 생성 ERROR: ', err);
            throw err;
        }
    },
    deleteUserInterest: async(userIdx, categoryIdx) => {
        const query = `UPDATE UserInterestTB SET status = 'D' WHERE userIdx = ? and categoryIdx = ?;`
        const params = [userIdx,categoryIdx];
        try {
            const result = await pool.queryParam(query,params);
            return [result];
        } catch (err) {
            console.log('유저 관심 카테고리 수정 ERROR : ', err);
            throw err;
        }
    },
    reuseUserInterest: async(userIdx, categoryIdx) => {
        const query = `UPDATE UserInterestTB SET status = 'Y' WHERE userIdx = ? and categoryIdx = ?;`
        const params = [userIdx,categoryIdx];
        try {
            const result = await pool.queryParam(query,params);
            return [result];
        } catch (err) {
            console.log('유저 관심 카테고리 수정 ERROR : ', err);
            throw err;
        }
    },
    selectUserInterest: async(userIdx) => {
        const query = `
            SELECT categoryIdx, name
            FROM UserInterestTB UI
                INNER JOIN CategoryTB C ON C.idx = UI.categoryIdx
            WHERE UI.userIdx = ? and UI.status = 'Y'
        `;
        const params = [userIdx];
        try {
            const result = await pool.queryParam(query,params);
            return [result];
        } catch (err) {
            console.log('유저 관심 카테고리 조회 ERROR: ', err);
            throw err;
        }
    }
}

module.exports = users;
