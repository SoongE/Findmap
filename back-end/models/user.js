//const pool = require('../modules/pool');
const pool = require('../config/database');
const { logger } = require("../modules/winston");

const user = {
    userIdCheck: async(id) => {
        const query = `SELECT id FROM UserTB WHERE id = ? and status = 'Y'`;
        const params = [id];
        try {
            const connection = await pool.getConnection(async (conn) => conn);
            const [result] = await connection.query(query,params);
            connection.release();
            return result;
        } catch (err) {
            logger.error(`App - IDCheck Query error\n: ${err.message}`);
            return res.status(500).send(`Error: ${err.message}`);
        }
    },
    userEmailCheck: async(email) => {
        const query = `SELECT email FROM UserTB WHERE email = ? and status = 'Y'`;
        const params = [email];
        try {
            const connection = await pool.getConnection(async (conn) => conn);
            const [result] = await connection.query(query,params);
            connection.release();
            return result;
        } catch (err) {
            logger.error(`App - EmailCheck Query error\n: ${err.message}`);
            return res.status(500).send(`Error: ${err.message}`);
        }
    },
    userPhoneNumCheck: async(phoneNum) => {
        const query = `SELECT phoneNum FROM UserTB WHERE phoneNum = ? and status = 'Y'`;
        const params = [phoneNum];
        try {
            const connection = await pool.getConnection(async (conn) => conn);
            const [result] = await connection.query(query,params);
            connection.release();
            return result;
        } catch (err) {
            logger.error(`App - PhoneNumCheck Query error\n: ${err.message}`);
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
            const connection = await pool.getConnection(async (conn) => conn);
            const [result] = await connection.query(query,params);
            connection.release();
            return [result];
        } catch (err) {
            logger.error(`App - SelectUser Query error\n: ${err.message}`);
            return res.status(500).send(`Error: ${err.message}`);
        }
    },
    signUp: async (id, password, name, nickName, profileUrl, birthday, gender, email, phoneNum) => {
        const fields = 'id, password, name, nickName, profileUrl, birthday, gender, email, phoneNum';
        const values = [id, password, name, nickName, profileUrl, birthday, gender, email, phoneNum];
        const query = `INSERT INTO UserTB(${fields}) VALUES(?,?,?,?,?,?,?,?,?)`;
        try {
            const connection = await pool.getConnection(async (conn) => conn);
            const [result] = await connection.query(query,values);
            connection.release();
            return result;
        } catch (err) {
            logger.error(`App - SignUp Query error\n: ${err.message}`);
            return res.status(500).send(`Error: ${err.message}`);
        }
    },
    signin: async (id, password, name, nickName, profileUrl, birthday, gender, email, phoneNum) => {
        const fields = 'id, password, name, nickName, profileUrl, birthday, gender, email, phoneNum'
        const values = [id, password, name, nickName, profileUrl, birthday, gender, email, phoneNum]

        const query = `INSERT INTO UserTB(${fields}) VALUES(?,?,?,?,?,?,?,?,?)`;
        try {
            const result = await pool.queryParamArr(query, values);
            const insertIdx = result.insertId;
            // const queryCategory = `INSERT INTO ${table_category}(userIdx,name) VALUES(${insertIdx},"전체")`
            // const categoryResult = await pool.queryParam(queryCategory)
            return insertIdx;
        } catch (err) {
            throw err
        }
    }
}

module.exports = user;