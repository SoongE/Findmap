const pool = require('../modules/pool');
const db = require('../config/database');

const users = {
    userIdCheck: async(id) => {
        const query = `SELECT id FROM UserTB WHERE id = ?`;
        const params = [id];
        try {
            const result = await pool.queryParam(query,params);
            return result;
        } catch (err) {
            console.log('idCheck ERROR: ', err);
            //return res.status(500).send(`Error: ${err.message}`);
            throw err;
        }
    },
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
    selectUserInfoById: async(id) => {
        const query = `
            SELECT idx, id, name, email, phoneNum 
            FROM UserTB
            WHERE id = ? and status = 'Y';`;
        const params = [id];
        try {
            const result = await pool.queryParam(query,params);
            return [result];
        } catch (err) {
            console.log('selectUserInfoById ERROR: ', err);
            throw err;
        }
    },
    signUp: async (id, password, name, nickName, profileUrl, birthday, gender, email, phoneNum) => {
        const fields = 'id, password, name, nickName, profileUrl, birthday, gender, email, phoneNum';
        const values = [id, password, name, nickName, profileUrl, birthday, gender, email, phoneNum];
        const query = `INSERT INTO UserTB(${fields}) VALUES(?,?,?,?,?,?,?,?,?)`;
        try {
            const result = await pool.queryParamArr(query, values);
            return result;
        } catch (err) {
            console.log('signUp ERROR: ', err);
            throw err;
        }
    },
    checkJWT: async(userIdx) => {
        const query = `SELECT userIdx FROM TokenTB WHERE userIdx = ?;`;
        const params = [userIdx];
        try {
            const result = await pool.queryParam(query,params);
            return [result];
        } catch (err) {
            console.log('checkJWT ERROR: ', err);
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
    }
}

module.exports = users;