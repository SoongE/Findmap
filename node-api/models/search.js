const pool = require('../modules/pool');

const search = {
    searchFeed: async(searchQuery) => {
        const query = `
        SELECT
              S.idx AS scrapIdx
             , UT.idx AS userIdx
             , UT.nickName AS userNickName
             , IFNULL(UT.profileUrl, 'N') as userProfile
             , title, contentUrl, thumbnailUrl, summary
             , IFNULL(S.comment, '') as comment
             , date_format(S.createdAt, '%Y년 %m월 %d일')  AS createdDate
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
            WHERE S.isFeed = 'Y' and S.status = 'Y' and (S.title LIKE '%${searchQuery}%' or S.summary LIKE '%${searchQuery}%' or S.comment LIKE '%${searchQuery}%');`
        const params = [searchQuery];
        try {
            const result = await pool.queryParam(query,params);
            return result;
        } catch (err) {
            console.log('검색 ERROR: ', err);
            throw err;
        }
    },
    insertSearchWord: async(searchQuery) => {
        const query = `
            INSERT INTO SearchWordTB(word)
            VALUES(?);
        `;
        const params = [searchQuery];
        try {
            const result = await pool.queryParam(query,params);
            return result;
        } catch (err) {
            console.log('Search Word insert ERROR: ', err);
            throw err;
        }
    },
    selectSearchWord: async(searchQuery) => {
        const query = `
            SELECT word
            FROM SearchWordTB
            WHERE word = ?;
        `;
        const params = [searchQuery];
        try {
            const result = await pool.queryParam(query,params);
            return result;
        } catch (err) {
            console.log('Search Word 조회 ERROR: ', err);
            throw err;
        }
    },
    updateSearchWord: async(searchQuery) => {
        const query = `
            UPDATE SearchWordTB
            SET count = count + 1
            WHERE word = ?;
        `
        const params = [searchQuery];
        try {
            const result = await pool.queryParam(query,params);
            return [result];
        } catch (err) {
            console.log('Search Word 수정 ERROR : ', err);
            throw err;
        }
    },
    insertSearchLog: async(userIdx,searchQuery) => {
        const fields = 'userIdx,word';
        const values = [userIdx,searchQuery];
        const query = `INSERT INTO SearchLogTB(${fields}) VALUES(?,?)`;
        try {
            const result = await pool.queryParamArr(query, values);
            return result;
        } catch (err) {
            console.log('검색 기록 생성 ERROR: ', err);
            throw err;
        }
    },
    selectSearchLog: async(userIdx) => {
        const query = `SELECT * FROM SearchLogTB WHERE userIdx = ? and status = 'Y' ORDER BY createdAt DESC`;
        const params = [userIdx];
        try {
            const result = await pool.queryParam(query,params);
            return result;
        } catch (err) {
            console.log('검색 기록 조회 ERROR: ', err);
            throw err;
        }
    },
    checkSearchLog: async(userIdx,wordIdx) => {
        const query = `SELECT * FROM SearchLogTB WHERE userIdx = ? and idx = ? and status = 'Y' ORDER BY createdAt DESC`;
        const params = [userIdx, wordIdx];
        try {
            const result = await pool.queryParam(query,params);
            return result;
        } catch (err) {
            console.log('검색 기록 조회 ERROR: ', err);
            throw err;
        }
    },
    deleteSearchLog: async(userIdx, wordIdx) => {
        const query = `UPDATE SearchLogTB SET status = 'D' WHERE userIdx = ? and idx = ?;`
        const params = [userIdx, wordIdx];
        try {
            const result = await pool.queryParam(query,params);
            return [result];
        } catch (err) {
            console.log('검색 기록 삭제 ERROR : ', err);
            throw err;
        }
    },
    searchUser: async(searchQuery) => {
        const query = `
        SELECT
            U.idx AS userIdx
            , U.nickName AS userNickName
            , IFNULL(U.profileUrl, 'N') as userProfile
            , (select COUNT(*) FROM FollowTB F where F.followerIdx = U.idx) as followerCount
            , (select COUNT(*) FROM FollowTB F where F.followingIdx = U.idx) as followingCount
            , IFNULL((select F.status FROM FollowTB F where F.followingIdx = U.idx),'N') as followStatus
            FROM UserTB U
            WHERE U.status = 'Y' and (U.nickName LIKE '%${searchQuery}%');`
        const params = [searchQuery];
        try {
            const result = await pool.queryParam(query,params);
            return result;
        } catch (err) {
            console.log('검색 ERROR: ', err);
            throw err;
        }
    },
    insertHotSearchWord: async(userIdx) => {
        const query = `
        INSERT INTO SearchWord(searchWord)
        VALUES('${searchQuery}');
        `;
        const params = [userIdx];
        try {
            const result = await pool.queryParam(query,params);
            return result;
        } catch (err) {
            console.log('폴더 상세 조회 ERROR: ', err);
            throw err;
        }
    },
    selectOldRanking: async(userIdx, folderIdx) => {
        const query = `
            SELECT wordIdx, ranking, changes
            FROM SearchRankingTB;
        `;
        const params = [userIdx, folderIdx];
        try {
            const result = await pool.queryParam(query,params);
            return result;
        } catch (err) {
            console.log('랭킹 조회 ERROR: ', err);
            throw err;
        }
    },
    selectHotSearchWord: async(userIdx, folderIdx) => {
        const query = `
        select 
            idx, 
            word,
            count,
            @vRank := @vRank + 1 AS ranking
        FROM SearchWordTB AS S, (SELECT @vRank := 0) R ORDER BY count DESC
        LIMIT 0, 15
        `;
        const params = [userIdx, folderIdx];
        try {
            const result = await pool.queryParam(query,params);
            return result;
        } catch (err) {
            console.log('핫 랭킹 조회 ERROR: ', err);
            throw err;
        }
    },
    selectRanking: async(userIdx, folderIdx) => {
        const query = `
            SELECT 
                word, 
                ranking,
                case when changes is null or changes = ""
                    then 'new'
                    else changes
                end as changes
            FROM SearchRankingTB SR
                INNER JOIN SearchWordTB SW on SW.idx = SR.wordIdx
            GROUP BY wordIdx;
        `;
        const params = [userIdx, folderIdx];
        try {
            const result = await pool.queryParam(query,params);
            return result;
        } catch (err) {
            console.log('랭킹 조회 ERROR: ', err);
            throw err;
        }
    },
    insertRanking: async(wordIdx, ranking, changes) => {
        const fields = 'wordIdx, ranking, changes';
        const values = [wordIdx, ranking, changes];
        const query = `INSERT INTO SearchRankingTB(${fields}) VALUES(?,?,?)`;
        try {
            const result = await pool.queryParamArr(query, values);
            return result;
        } catch (err) {
            console.log('랭킹 생성 ERROR: ', err);
            throw err;
        }
    },
    updateChange: async(wordIdx,change) => {
        const query = `UPDATE SearchRankingTB SET changes = ? WHERE wordIdx = ?;`
        const params = [change, wordIdx];
        try {
            const result = await pool.queryParam(query,params);
            return [result];
        } catch (err) {
            console.log('랭킹 수정 ERROR : ', err);
            throw err;
        }
    },
    deleteRanking: async() => {
        const query = `DELETE FROM SearchRankingTB;`
        const params = [];
        try {
            const result = await pool.queryParam(query,params);
            return [result];
        } catch (err) {
            console.log('랭킹 삭제 ERROR : ', err);
            throw err;
        }
    },
}


module.exports = search;