const pool = require('../modules/pool');

const follow = {
    checkFollow: async(followerIdx, followingIdx) => {
        const query = `SELECT * FROM FollowTB WHERE followerIdx = ? and followingIdx = ?;`
        const params = [followerIdx, followingIdx];
        try {
            const result = await pool.queryParam(query,params);
            return [result];
        } catch (err) {
            console.log('follow check ERROR: ', err);
            throw err;
        }
    },
    postFollow: async(followerIdx, followingIdx) => {
        const fields = 'followerIdx, followingIdx';
        const values = [followerIdx, followingIdx];
        const query = `INSERT INTO FollowTB(${fields}) VALUES(?,?)`;
        try {
            const result = await pool.queryParamArr(query, values);
            return result;
        } catch (err) {
            console.log('Follow ERROR: ', err);
            throw err;
        }
    },
    deleteFollow: async(followerIdx, followingIdx) => {
        const query = `UPDATE FollowTB SET status = 'D' WHERE followerIdx = ? and followingIdx = ?;`
        const params = [followerIdx, followingIdx];
        try {
            const result = await pool.queryParam(query,params);
            return [result];
        } catch (err) {
            console.log('follow 취소 ERROR : ', err);
            throw err;
        }
    },
    reuseFollow: async(followerIdx, followingIdx) => {
        const query = `UPDATE FollowTB SET status = 'Y' WHERE followerIdx = ? and followingIdx = ?;`
        const params = [followerIdx, followingIdx];
        try {
            const result = await pool.queryParam(query,params);
            return [result];
        } catch (err) {
            console.log('reFollow ERROR : ', err);
            throw err;
        }
    },
    selectFollowerList: async(userIdx) => {
        const query = `
            SELECT U.idx, U.profileUrl, U.nickName, U.description
            FROM UserTB U
                INNER JOIN FollowTB F ON U.idx = F.followerIdx
            WHERE F.followingIdx = ? and F.status = 'Y';
        `;
        const params = [userIdx];
        try {
            const result = await pool.queryParam(query,params);
            return [result];
        } catch (err) {
            console.log('followerList 조회 ERROR: ', err);
            throw err;
        }
    },
    selectFollowingList: async(userIdx) => {
        const query = `
            SELECT U.idx, U.profileUrl, U.nickName, U.description
            FROM UserTB U
                INNER JOIN FollowTB F ON U.idx = F.followingIdx
            WHERE F.followerIdx = ? and F.status = 'Y';
        `;
        const params = [userIdx];
        try {
            const result = await pool.queryParam(query,params);
            return [result];
        } catch (err) {
            console.log('followingList 조회 ERROR: ', err);
            throw err;
        }
    },
    checkFollowing: async(userIdx) => {
        const query =  `SELECT * FROM FollowTB WHERE followingIdx = ? and status = 'Y';`
        const params = [userIdx];
        try {
            const result = await pool.queryParam(query,params);
            return [result];
        } catch (err) {
            console.log('following check ERROR: ', err);
            throw err;
        }
    },
    checkFollower: async(userIdx) => {
        const query =  `SELECT * FROM FollowTB WHERE followerIdx = ? and status = 'Y';`
        const params = [userIdx];
        try {
            const result = await pool.queryParam(query,params);
            return [result];
        } catch (err) {
            console.log('follower check ERROR: ', err);
            throw err;
        }
    }
}

module.exports = follow;
