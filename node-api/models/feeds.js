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
    selectProfile: async(userIdx) => {
        const query = `
        SELECT 
            U.idx,
            U.profileUrl,
            U.nickName,
            U.description,
            (SELECT COUNT(*) FROM ScrapTB S WHERE U.idx = S.userIdx) AS ScrapCount,
            (SELECT COUNT(*) FROM FollowTB F WHERE U.idx = F.followerIdx) AS FollowCount,
            (SELECT COUNT(*) FROM FeedHeartTB FH WHERE FH.userIdx = U.idx) AS HaertCount
        FROM UserTB U
            WHERE U.idx = ? and U.status = 'Y'
        `;
        const params = [userIdx];
        try {
            const result = await pool.queryParam(query,params);
            return [result];
        } catch (err) {
            console.log('유저 프로필 조회 ERROR: ', err);
            throw err;
        }
    },
    selectFeed: async(userIdx) => {
        const query = `
        SELECT
              S.idx AS scrapIdx
             , UT.idx AS userIdx
             , UT.nickName AS userNickName
             , IFNULL(UT.profileUrl, 'N') as userProfile
             , title, contentUrl, thumbnailUrl, summary
             , IFNULL(S.comment, '') as comment
             , date_format(S.createdAt, '%Y년 %m월 %d일 %H:%i')  AS createdAt
             , case
                    when timestampdiff(second, S.createdAt, current_timestamp) <= 60
                        then concat(timestampdiff(second, S.createdAt, current_timestamp), '초 전')
                    when timestampdiff(minute, S.createdAt, current_timestamp) <= 60
                        then concat(timestampdiff(minute, S.createdAt, current_timestamp), '분 전')
                    when timestampdiff(hour, S.createdAt, current_timestamp) <= 24
                        then concat(timestampdiff(hour, S.createdAt, current_timestamp), '시간 전')
                    when timestampdiff(day, S.createdAt, current_timestamp) <= 7
                        then concat(timestampdiff(day, S.createdAt, current_timestamp), '일 전')
                    when timestampdiff(week, S.createdAt, current_timestamp) <= 4 and timestampdiff(week, S.createdAt, current_timestamp) >= 1
                        then concat(timestampdiff(week, S.createdAt, current_timestamp), '주 전')
                    when timestampdiff(month, S.createdAt, current_timestamp) <= 12 and timestampdiff(month, S.createdAt, current_timestamp) >= 1
                        then concat(timestampdiff(month, S.createdAt, current_timestamp), '개월 전')
                    else concat(timestampdiff(year, S.createdAt, current_timestamp), '년 전')
                end as createdTerm
             , (select COUNT(*) FROM FeedHeartTB FHT where FHT.scrapIdx = S.idx) as scrapLikeCount
             , (select COUNT(*) FROM FeedStorageTB FHT where FHT.scrapIdx = S.idx) as scrapStorageCount
             , IFNULL((select SUM(count) FROM FeedHistoryTB FHT where FHT.scrapIdx = S.idx),0) as scrapHistoryCount
             , IFNULL((select FHT.status from FeedHeartTB FHT where FHT.userIdx = S.userIdx and FHT.scrapIdx = S.idx),'N') AS userLikeStatus
             , IFNULL((select FHT.status from FeedHistoryTB FHT where FHT.userIdx = S.userIdx and FHT.scrapIdx = S.idx),'N') AS userHistoryStatus
             , IFNULL((select FST.status from FeedStorageTB FST where FST.userIdx = S.userIdx and FST.scrapIdx = S.idx),'N') AS userStorageStatus
            FROM ScrapTB S
                INNER JOIN UserTB UT ON UT.idx = S.userIdx
            WHERE S.userIdx = ? and S.isFeed = 'Y' and S.status = 'Y'
            ORDER BY S.createdAt DESC;
        `;
        const params = [userIdx];
        try {
            const result = await pool.queryParam(query,params);
            return [result];
        } catch (err) {
            console.log('피드 조회 ERROR: ', err);
            throw err;
        }
    },
    selectFollowingFeed: async(userIdx) => {
        const query = `
        SELECT
            S.idx AS scrapIdx
            , UT.idx AS userIdx
            , UT.nickName AS userNickName
            , IFNULL(UT.profileUrl, 'N') as userProfile
            , title, contentUrl, thumbnailUrl, summary
            , IFNULL(S.comment, '') as comment
            , date_format(S.createdAt, '%Y년 %m월 %d일 %H:%i')  AS createdAt
            , case
                when timestampdiff(second, S.createdAt, current_timestamp) <= 60
                    then concat(timestampdiff(second, S.createdAt, current_timestamp), '초 전')
                when timestampdiff(minute, S.createdAt, current_timestamp) <= 60
                    then concat(timestampdiff(minute, S.createdAt, current_timestamp), '분 전')
                when timestampdiff(hour, S.createdAt, current_timestamp) <= 24
                    then concat(timestampdiff(hour, S.createdAt, current_timestamp), '시간 전')
                when timestampdiff(day, S.createdAt, current_timestamp) <= 7
                    then concat(timestampdiff(day, S.createdAt, current_timestamp), '일 전')
                when timestampdiff(week, S.createdAt, current_timestamp) <= 4 and timestampdiff(week, S.createdAt, current_timestamp) >= 1
                    then concat(timestampdiff(week, S.createdAt, current_timestamp), '주 전')
                when timestampdiff(month, S.createdAt, current_timestamp) <= 12 and timestampdiff(month, S.createdAt, current_timestamp) >= 1
                    then concat(timestampdiff(month, S.createdAt, current_timestamp), '개월 전')
                else concat(timestampdiff(year, S.createdAt, current_timestamp), '년 전')
            end as createdTerm
            , (select COUNT(*) FROM FeedHeartTB FHT where FHT.scrapIdx = S.idx) as scrapLikeCount
            , (select COUNT(*) FROM FeedStorageTB FHT where FHT.scrapIdx = S.idx) as scrapStorageCount
            , IFNULL((select SUM(count) FROM FeedHistoryTB FHT where FHT.scrapIdx = S.idx),0) as scrapHistoryCount
            , IFNULL((select FHT.status from FeedHeartTB FHT where FHT.userIdx = S.userIdx and FHT.scrapIdx = S.idx),'N') AS userLikeStatus
            , IFNULL((select FHT.status from FeedHistoryTB FHT where FHT.userIdx = S.userIdx and FHT.scrapIdx = S.idx),'N') AS userHistoryStatus
            , IFNULL((select FST.status from FeedStorageTB FST where FST.userIdx = S.userIdx and FST.scrapIdx = S.idx),'N') AS userStorageStatus
            FROM ScrapTB S
            INNER JOIN UserTB UT ON UT.idx = S.userIdx
                INNER JOIN FollowTB F ON F.followingIdx = S.userIdx
            WHERE F.followerIdx = ? and S.isFeed = 'Y' and S.status = 'Y'
            ORDER BY S.createdAt DESC;
        `;
        const params = [userIdx];
        try {
            const result = await pool.queryParam(query,params);
            return [result];
        } catch (err) {
            console.log('팔로잉 피드 조회 ERROR: ', err);
            throw err;
        }
    }
}

module.exports = feed;
