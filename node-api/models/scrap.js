const pool = require('../modules/pool');
const db = require('../config/database');
const { param } = require('../routes');

const scrap = {
    postScrap: async(userIdx, title, contentUrl, thumbnailUrl, summary, comment, categoryIdx, folderIdx) => {
        const fields = 'userIdx, title, contentUrl, thumbnailUrl, summary, comment, categoryIdx, folderIdx';
        const values = [userIdx, title, contentUrl, thumbnailUrl, summary, comment, categoryIdx, folderIdx];
        const query = `INSERT INTO ScrapTB(${fields}) VALUES(?,?,?,?,?,?,?,?,?)`;
        try {
            const result = await pool.queryParamArr(query, values);
            return result;
        } catch (err) {
            console.log('스크랩 생성 ERROR: ', err);
            throw err;
        }
    },
    selectScrap: async(userIdx) => {
        const query = `SELECT idx, title, contentUrl, thumbnailUrl, summary, comment, categoryIdx, folderIdx
        FROM ScrapTB WHERE userIdx = ? and status = 'Y' ORDER BY updatedAt DESC`;
        const params = [userIdx];
        try {
            const result = await pool.queryParam(query,params);
            return result;
        } catch (err) {
            console.log('아카이브 조회 ERROR: ', err);
            throw err;
        }
    },
    selectScrapByFolder: async(userIdx,folderIdx) => {
        const query = `SELECT idx, title, contentUrl, thumbnailUrl, summary, comment, categoryIdx, folderIdx 
        FROM ScrapTB WHERE userIdx = ? and folderIdx = ? and status = 'Y' ORDER BY updatedAt DESC`;
        const params = [userIdx,folderIdx];
        try {
            const result = await pool.queryParam(query,params);
            return result;
        } catch (err) {
            console.log('아카이브 폴더별 조회 ERROR: ', err);
            throw err;
        }
    },
    selectScrapByCategory: async(userIdx,categoryIdx) => {
        const query = `SELECT idx, title, contentUrl, thumbnailUrl, summary, comment, categoryIdx, folderIdx 
        FROM ScrapTB WHERE userIdx = ? and categoryIdx = ? and status = 'Y'ORDER BY updatedAt DESC`;
        const params = [userIdx,categoryIdx];
        try {
            const result = await pool.queryParam(query,params);
            return result;
        } catch (err) {
            console.log('아카이브 카테고리별 조회 ERROR: ', err);
            throw err;
        }
    },
    selectScrapByDate: async(userIdx,date) => {
        const query = `SELECT idx, title, contentUrl, thumbnailUrl, summary, comment, categoryIdx, folderIdx
        FROM ScrapTB WHERE userIdx = ? and date_format(updatedAt, '%Y%m%d')= ? and status = 'Y' ORDER BY updatedAt DESC`;
        const params = [userIdx,date];
        try {
            const result = await pool.queryParam(query,params);
            return result;
        } catch (err) {
            console.log('아카이브 날짜별 조회 ERROR: ', err);
            throw err;
        }
    },
    selectScrapDetail: async(userIdx, scrapIdx) => {
        const query = `SELECT idx, title, contentUrl, thumbnailUrl, summary, comment, categoryIdx, folderIdx, createdAt, updatedAt, status 
        FROM ScrapTB WHERE userIdx = ? and idx = ? and status = 'Y'ORDER BY updatedAt DESC`;
        const params = [userIdx, scrapIdx];
        try {
            const result = await pool.queryParam(query,params);
            return result;
        } catch (err) {
            console.log('스크랩 상세 조회 ERROR: ', err);
            throw err;
        }
    },
    updateScrapTitle: async(userIdx, scrapIdx, title) => {
        const query = `UPDATE ScrapTB SET title = ? WHERE userIdx = ? and idx = ?;`
        const params = [title, userIdx, scrapIdx];
        try {
            const result = await pool.queryParam(query,params);
            return [result];
        } catch (err) {
            console.log('스크랩 feedIdx 수정 ERROR : ', err);
            throw err;
        }
    },
    updateScrapSummary: async(userIdx, scrapIdx, summary) => {
        const query = `UPDATE ScrapTB SET summary = ? WHERE userIdx = ? and idx = ?;`
        const params = [summary, userIdx, scrapIdx];
        try {
            const result = await pool.queryParam(query,params);
            return [result];
        } catch (err) {
            console.log('스크랩 categoryIdx 수정 ERROR : ', err);
            throw err;
        }
    },
    updateScrapComment: async(userIdx, scrapIdx, comment) => {
        const query = `UPDATE ScrapTB SET comment = ? WHERE userIdx = ? and idx = ?;`
        const params = [comment, userIdx, scrapIdx];
        try {
            const result = await pool.queryParam(query,params);
            return [result];
        } catch (err) {
            console.log('스크랩 comment 수정 ERROR : ', err);
            throw err;
        }
    },
    updateScrapFolder: async(userIdx, scrapIdx, folderIdx) => {
        const query = `UPDATE ScrapTB SET folderIdx = ? WHERE userIdx = ? and idx = ?;`
        const params = [folderIdx, userIdx, scrapIdx];
        try {
            const result = await pool.queryParam(query,params);
            return [result];
        } catch (err) {
            console.log('스크랩 folderIdx 수정 ERROR : ', err);
            throw err;
        }
    },
    deleteScrap: async(userIdx, scrapIdx) => {
        const query = `UPDATE ScrapTB SET status = 'D' WHERE userIdx = ? and idx = ?;`
        const params = [userIdx, scrapIdx];
        try {
            const result = await pool.queryParam(query,params);
            return [result];
        } catch (err) {
            console.log('스크랩 삭제 ERROR : ', err);
            throw err;
        }
    }
}

module.exports = scrap;

/*
    checkScrap: async(userIdx) => {
        const query = `SELECT idx FROM ScrapTB 
        WHERE userIdx = ? and title = ? and contentUrl = ? and thumbnailUrl = ? and summary = ? and comment = ? 
        and categoryIdx = ? and folderIdx = ? and feedIdx = ?`;
        const params = [userIdx, title, contentUrl, thumbnailUrl, summary, comment, categoryIdx, folderIdx, feedIdx];
        try {
            const result = await pool.queryParam(query,params);
            return result;
        } catch (err) {
            console.log('scrap 확인 ERROR: ', err);
            throw err;
        }
    }
*/

