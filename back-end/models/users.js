const pool = require('../modules/pool');
const db = require('../config/database');

const users = {
    userIdCheck: async(id) => {
        const query = `SELECT id FROM UserTB WHERE id = ? and status = 'Y'`;
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
        const query = `SELECT email FROM UserTB WHERE email = ? and status = 'Y'`;
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
        const query = `SELECT phoneNum FROM UserTB WHERE phoneNum = ? and status = 'Y'`;
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
    }
}

module.exports = users;