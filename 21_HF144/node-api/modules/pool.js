const poolPromise = require('../config/database');

module.exports = {
    queryParam: async (query,params) => {
        return new Promise ( async (resolve, reject) => {
            try {
                const pool = await poolPromise;
                const connection = await pool.getConnection();
                try {
                    const [result] = await connection.query(query,params);
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
    queryParamArr: async (query, values) => {
        return new Promise(async (resolve, reject) => {
            try {
                const pool = await poolPromise;
                const connection = await pool.getConnection();
                try {
                    const result = await connection.query(query, values);
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