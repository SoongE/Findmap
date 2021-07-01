const poolPromise = require('../config/database');

module.exports = {
    queryParam: async (query,param) => {
        return new Promise ( async (resolve, reject) => {
            try {
                const pool = await poolPromise;
                const connection = await pool.getConnection();
                try {
                    const [result] = await connection.query(query,param);
                    connection.release(connection);
                    resolve(result);
                } catch (err) {
                    connection.release(connection);
                    reject(err);
                }
            } catch (err) {
                reject(err);
            }
        });
    },
    queryParamArr: async (query, value) => {
        return new Promise(async (resolve, reject) => {
            try {
                const pool = await poolPromise;
                const connection = await pool.getConnection();
                try {
                    const result = await connection.query(query, value);
                    connection.release(connection);
                    resolve(result);
                } catch (err) {
                    connection.release(connection);
                    reject(err);
                }
            } catch (err) {
                reject(err);
            }
        });
    },
    Transaction: async (...args) => {
        return new Promise(async (resolve, reject) => {
            try {
                const pool = await poolPromise;
                const connection = await pool.getConnection();
                try {
                    await connection.beginTransaction();
                    args.forEach(async (it) => await it(connection));
                    await connection.commit();
                    connection.release(connection);
                    resolve(result);
                } catch (err) {
                    await connection.rollback()
                    connection.release(connection);
                    reject(err);
                }
            } catch (err) {
                reject(err);
            }
        });
    }
}