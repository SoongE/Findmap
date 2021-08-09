const pool = require('../modules/pool');

const scrap = {
    postScrap: async(userIdx, title, contentUrl, thumbnailUrl, summary, comment, categoryIdx, folderIdx, isFeed) => {
        const fields = 'userIdx, title, contentUrl, thumbnailUrl, summary, comment, categoryIdx, folderIdx, isFeed';
        const values = [userIdx, title, contentUrl, thumbnailUrl, summary, comment, categoryIdx, folderIdx, isFeed];
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
        const query = `SELECT * FROM ScrapTB WHERE userIdx = ? and status = 'Y' ORDER BY createdAt DESC`;
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
        const query = `SELECT * FROM ScrapTB WHERE userIdx = ? and folderIdx = ? and status = 'Y' ORDER BY createdAt DESC`;
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
        const query = `SELECT * FROM ScrapTB WHERE userIdx = ? and categoryIdx = ? and status = 'Y'ORDER BY createdAt DESC`;
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
        const query = `SELECT * FROM ScrapTB WHERE userIdx = ? and date_format(updatedAt, '%Y%m%d')= ? and status = 'Y' ORDER BY createdAt DESC`;
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
        const query = `SELECT * FROM ScrapTB WHERE userIdx = ? and idx = ? and status = 'Y'`;
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
    updateScrapFeed: async(userIdx, scrapIdx, isFeed) => {
        const query = `UPDATE ScrapTB SET isFeed = ? WHERE userIdx = ? and idx = ?;`
        const params = [isFeed, userIdx, scrapIdx];
        try {
            const result = await pool.queryParam(query,params);
            return [result];
        } catch (err) {
            console.log('스크랩 isFeed 수정 ERROR : ', err);
            throw err;
        }
    },
    updateScrapFeedUp: async(userIdx, scrapIdx) => {
        const query = `UPDATE ScrapTB SET isFeed = 'Y' WHERE userIdx = ? and idx = ?;`
        const params = [userIdx, scrapIdx];
        try {
            const result = await pool.queryParam(query,params);
            return [result];
        } catch (err) {
            console.log('스크랩 isFeed 수정 ERROR : ', err);
            throw err;
        }
    },
    updateScrapFeedDown: async(userIdx, scrapIdx) => {
        const query = `UPDATE ScrapTB SET isFeed = 'N' WHERE userIdx = ? and idx = ?;`
        const params = [userIdx, scrapIdx];
        try {
            const result = await pool.queryParam(query,params);
            return [result];
        } catch (err) {
            console.log('스크랩 isFeed 수정 ERROR : ', err);
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
    },
    moveFolderScrap: async(userIdx, folderIdx, moveFolderIdx) => {
        const query = `UPDATE ScrapTB SET folderIdx = ? WHERE userIdx = ? and folderIdx = ?;`
        const params = [moveFolderIdx, userIdx, folderIdx];
        try {
            const result = await pool.queryParam(query,params);
            return [result];
        } catch (err) {
            console.log('폴더 안 스크랩 이동 ERROR : ', err);
            throw err;
        }
    },
    deleteFolderScrap: async(userIdx, folderIdx) => {
        const query = `UPDATE ScrapTB SET status = 'D' WHERE userIdx = ? and folderIdx = ?;`
        const params = [userIdx, folderIdx];
        try {
            const result = await pool.queryParam(query,params);
            return [result];
        } catch (err) {
            console.log('폴더 안 스크랩 삭제 ERROR : ', err);
            throw err;
        }
    }
}

module.exports = scrap;
