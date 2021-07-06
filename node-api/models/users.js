const pool = require('../modules/pool');
const db = require('../config/database');

const users = {
    userEmailCheck: async(email) => {
        const query = `SELECT idx,email,password,status FROM UserTB WHERE email = ?`;
        const params = [email];
        try {
            const result = await pool.queryParam(query,params);
            return result;
        } catch (err) {
            console.log('emailCheck ERROR: ', err);
            throw err;
        }
    },
    userPhoneNumCheck: async(phoneNum) => {
        const query = `SELECT phoneNum FROM UserTB WHERE phoneNum = ?`;
        const params = [phoneNum];
        try {
            const result = await pool.queryParam(query,params);
            return result;
        } catch (err) {
            console.log('phoneNumCheck ERROR: ', err);
            throw err;
        }
    },
    selectUserInfoByEmail: async(email) => {
        const query = `
            SELECT idx, name, email, phoneNum 
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
    signUp: async (email, password, name, nickName, profileUrl, birthday, gender, phoneNum) => {
        const fields = 'email, password, name, nickName, profileUrl, birthday, gender,  phoneNum';
        const values = [email, password, name, nickName, profileUrl, birthday, gender, phoneNum];
        const query = `INSERT INTO UserTB(${fields}) VALUES(?,?,?,?,?,?,?,?)`;
        try {
            const result = await pool.queryParamArr(query, values);
            return result;
        } catch (err) {
            console.log('signUp ERROR: ', err);
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
    checkJWT: async(userIdx) => {
        const query = `SELECT userIdx,token FROM TokenTB WHERE userIdx = ?;`;
        const params = [userIdx];
        try {
            const result = await pool.queryParam(query,params);
            return [result];
        } catch (err) {
            console.log('checkJWT ERROR: ', err);
            throw err;
        }
    },
    deleteJWT: async(userIdx) => {
        const query = `DELETE FROM TokenTB WHERE userIdx = ?;`;
        const params = [userIdx];
        try {
            const result = await pool.queryParam(query,params);
            return [result];
        } catch (err) {
            console.log('checkJWT ERROR: ', err);
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
            console.log('checkJWT ERROR: ', err);
            throw err;
        }
    }
}

module.exports = users;