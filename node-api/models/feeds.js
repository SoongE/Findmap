const pool = require('../modules/pool');

const feed = {
    checkStorage: async(userIdx,scrapIdx) => {
        const query = `SELECT * FROM FeedStorageTB WHERE userIdx = ? and scrapIdx = ?;`
        const params = [userIdx,scrapIdx];
        try {
            const result = await pool.queryParam(query,params);
            return [result];
        } catch (err) {
            console.log('storage check ERROR: ', err);
            throw err;
        }
    },
    postStorage: async(userIdx,scrapIdx) => {
        const fields = 'userIdx,scrapIdx';
        const values = [userIdx,scrapIdx];
        const query = `INSERT INTO FeedStorageTB(${fields}) VALUES(?,?)`;
        try {
            const result = await pool.queryParamArr(query, values);
            return result;
        } catch (err) {
            console.log('storage ERROR: ', err);
            throw err;
        }
    },
    deleteStorage: async(userIdx,scrapIdx) => {
        const query = `UPDATE FeedStorageTB SET status = 'D' WHERE userIdx = ? and scrapIdx = ?;`
        const params = [userIdx,scrapIdx];
        try {
            const result = await pool.queryParam(query,params);
            return [result];
        } catch (err) {
            console.log('storage 취소 ERROR : ', err);
            throw err;
        }
    },
    reuseStorage: async(userIdx,scrapIdx) => {
        const query = `UPDATE FeedStorageTB SET status = 'Y' WHERE userIdx = ? and scrapIdx = ?;`
        const params = [userIdx,scrapIdx];
        try {
            const result = await pool.queryParam(query,params);
            return [result];
        } catch (err) {
            console.log('reStorage ERROR : ', err);
            throw err;
        }
    },
    checkHeart: async(userIdx,scrapIdx) => {
        const query = `SELECT * FROM FeedHeartTB WHERE userIdx = ? and scrapIdx = ?;`
        const params = [userIdx,scrapIdx];
        try {
            const result = await pool.queryParam(query,params);
            return [result];
        } catch (err) {
            console.log('storage check ERROR: ', err);
            throw err;
        }
    },
    postHeart: async(userIdx,scrapIdx) => {
        const fields = 'userIdx,scrapIdx';
        const values = [userIdx,scrapIdx];
        const query = `INSERT INTO FeedHeartTB(${fields}) VALUES(?,?)`;
        try {
            const result = await pool.queryParamArr(query, values);
            return result;
        } catch (err) {
            console.log('heart ERROR: ', err);
            throw err;
        }
    },
    deleteHeart: async(userIdx,scrapIdx) => {
        const query = `UPDATE FeedHeartTB SET status = 'D' WHERE userIdx = ? and scrapIdx = ?;`
        const params = [userIdx,scrapIdx];
        try {
            const result = await pool.queryParam(query,params);
            return [result];
        } catch (err) {
            console.log('heart 취소 ERROR : ', err);
            throw err;
        }
    },
    reuseHeart: async(userIdx,scrapIdx) => {
        const query = `UPDATE FeedHeartTB SET status = 'Y' WHERE userIdx = ? and scrapIdx = ?;`
        const params = [userIdx,scrapIdx];
        try {
            const result = await pool.queryParam(query,params);
            return [result];
        } catch (err) {
            console.log('reHeart ERROR : ', err);
            throw err;
        }
    },
    checkHistory: async(userIdx,scrapIdx) => {
        const query = `SELECT * FROM FeedHistoryTB WHERE userIdx = ? and scrapIdx = ?;`
        const params = [userIdx,scrapIdx];
        try {
            const result = await pool.queryParam(query,params);
            return [result];
        } catch (err) {
            console.log('storage check ERROR: ', err);
            throw err;
        }
    },
    postHistory: async(userIdx,scrapIdx) => {
        const fields = 'userIdx,scrapIdx';
        const values = [userIdx,scrapIdx];
        const query = `INSERT INTO FeedHistoryTB(${fields}) VALUES(?,?)`;
        try {
            const result = await pool.queryParamArr(query, values);
            return result;
        } catch (err) {
            console.log('heart ERROR: ', err);
            throw err;
        }
    },
    addCountHistory: async(userIdx,scrapIdx,addCount) => {
        const query = `UPDATE FeedHistoryTB SET count = ? WHERE userIdx = ? and scrapIdx = ?;`
        const params = [addCount,userIdx,scrapIdx];
        try {
            const result = await pool.queryParam(query,params);
            return [result];
        } catch (err) {
            console.log('heart 취소 ERROR : ', err);
            throw err;
        }
    },
    selectMyFeed: async(userIdx) => {
        const query = `
            SELECT *
            FROM ScrapTB S
            WHERE S.userIdx = ? and S.isFeed = 'Y' and S.status = 'Y'
            ORDER BY createdAt DESC;
        `;
        const params = [userIdx];
        try {
            const result = await pool.queryParam(query,params);
            return [result];
        } catch (err) {
            console.log('내 피드 조회 ERROR: ', err);
            throw err;
        }
    }
}

module.exports = feed;
