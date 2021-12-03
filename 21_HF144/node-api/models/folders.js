const pool = require('../modules/pool');

const folder = {
    postFolder: async(userIdx, name) => {
        const fields = 'userIdx, name';
        const values = [userIdx, name];
        const query = `INSERT INTO FolderTB(${fields}) VALUES(?,?)`;
        try {
            const result = await pool.queryParamArr(query, values);
            return result;
        } catch (err) {
            console.log('폴더 생성 ERROR: ', err);
            throw err;
        }
    },
    selectFolder: async(userIdx) => {
        const query = `SELECT * FROM FolderTB WHERE userIdx = ? and status = 'Y' ORDER BY createdAt DESC`;
        const params = [userIdx];
        try {
            const result = await pool.queryParam(query,params);
            return result;
        } catch (err) {
            console.log('폴더 조회 ERROR: ', err);
            throw err;
        }
    },
    selectFolderDetail: async(userIdx, folderIdx) => {
        const query = `SELECT * FROM FolderTB WHERE userIdx = ? and idx = ? and status = 'Y'`;
        const params = [userIdx, folderIdx];
        try {
            const result = await pool.queryParam(query,params);
            return result;
        } catch (err) {
            console.log('폴더 상세 조회 ERROR: ', err);
            throw err;
        }
    },
    updateFolderName: async(userIdx, folderIdx, name) => {
        const query = `UPDATE FolderTB SET name = ? WHERE userIdx = ? and idx = ?;`
        const params = [name, userIdx, folderIdx];
        try {
            const result = await pool.queryParam(query,params);
            return [result];
        } catch (err) {
            console.log('폴더 name 수정 ERROR : ', err);
            throw err;
        }
    },
    deleteFolder: async(userIdx, folderIdx) => {
        const query = `UPDATE FolderTB SET status = 'D' WHERE userIdx = ? and idx = ?;`
        const params = [userIdx, folderIdx];
        try {
            const result = await pool.queryParam(query,params);
            return [result];
        } catch (err) {
            console.log('폴더 삭제 ERROR : ', err);
            throw err;
        }
    }
}

module.exports = folder;
