const pool = require('../modules/pool');
const db = require('../config/database');
const { logger } = require("../modules/winston");

const user = {
    userIdCheck: async(id) => {
        const query = `SELECT id FROM UserTB WHERE id = ? and status = 'Y'`;
        const params = [id];
        try {
            const result = await pool.queryParam(query,params);
            return result;
        } catch (err) {
            logger.error(`App - IDCheck Model error\n: ${err.message}`);
            return res.status(500).send(`Error: ${err.message}`);
        }
    },
    userEmailCheck: async(email) => {
        const query = `SELECT email FROM UserTB WHERE email = ? and status = 'Y'`;
        const params = [email];
        try {
            const result = await pool.queryParam(query,params);
            return result;
        } catch (err) {
            logger.error(`App - EmailCheck Model error\n: ${err.message}`);
            return res.status(500).send(`Error: ${err.message}`);
        }
    },
    userPhoneNumCheck: async(phoneNum) => {
        const query = `SELECT phoneNum FROM UserTB WHERE phoneNum = ? and status = 'Y'`;
        const params = [phoneNum];
        try {
            const result = await pool.queryParam(query,params);
            return result;
        } catch (err) {
            logger.error(`App - PhoneNumCheck Model error\n: ${err.message}`);
            return res.status(500).send(`Error: ${err.message}`);
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
            logger.error(`App - SelectUser Model error\n: ${err.message}`);
            return res.status(500).send(`Error: ${err.message}`);
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
            logger.error(`App - SignUp Model error\n: ${err.message}`);
            return res.status(500).send(`Error: ${err.message}`);
        }
    }
}

module.exports = user;