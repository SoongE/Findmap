//const pool = require('../modules/pool');
const pool = require('../config/database');
const { logger } = require("../modules/winston");

const user = {
    signup: async (id, password, name, nickName, profileUrl, birthday, gender, email, phoneNum) => {
        const fields = 'id, password, name, nickName, profileUrl, birthday, gender, email, phoneNum'
        const values = [id, password, name, nickName, profileUrl, birthday, gender, email, phoneNum]
        const query = `INSERT INTO UserTB(${fields}) VALUES(?,?,?,?,?,?,?,?,?)`;
        const params = [email];
        try {
            const connection = await pool.getConnection(async (conn) => conn);
            const [result] = await connection.query(query,values);
            connection.release();
            return result;
        } catch (err) {
            throw err
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