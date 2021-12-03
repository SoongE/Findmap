let folderModel = require('../models/folders');
let scrapModel = require('../models/scrap');

const folder = {
    postFolder: async (req, res) => {
        const userIdx = req.decoded.userIdx;
        let {name} = req.body;
        if (!name) return res.json({success: false, code: 2201, message: "name을 입력해 주세요."});

        console.log(name);
        try{
            const checkFolder = await folderModel.selectFolder(userIdx);

            if (checkFolder[0] !== undefined && checkFolder[0].name == name) {
                return res.json({success: true, code: 3201, message: "같은 이름의 폴더는 존재할 수 없습니다."});
            }
            const folderRow = await folderModel.postFolder(userIdx, name);

            return res.json({success: true, code: 1000, message: "폴더 등록 성공", result: {"insertId": folderRow[0].insertId}});
        } catch(err){
            return res.json({success: false, code: 4000, message: 'Server Error : ' + err.message});
        }
    },
    getFolder: async (req, res) => {
        const userIdx = req.decoded.userIdx;

        try {
            const folderRow = await folderModel.selectFolder(userIdx);
            if (folderRow[0] == undefined) {
              return res.json({success: false, code: 3202, message: "폴더가 존재하지 않습니다."});
            }
            return res.json({success: true, code: 1000, message: "폴더 전체 조회 성공", result: folderRow});
        } catch (err) {
            return res.json({success: false, code: 4000, message: 'Server Error : ' + err.message});
        }
    },
    getFolderDetail: async (req, res) => {
        const userIdx = req.decoded.userIdx;
        const folderIdx = req.params.folderIdx;

        try {
            const folderRow = await folderModel.selectFolderDetail(userIdx,folderIdx);
            if (folderRow[0] == undefined) {
              return res.json({success: false, code: 3202, message: "폴더가 존재하지 않습니다."});
            }
            return res.json({success: true, code: 1000, message: "폴더 상세 조회 성공", result: folderRow});
        } catch (err) {
            return res.json({success: false, code: 4000, message: 'Server Error : ' + err.message});
        }
    },
    patchFolder: async (req, res) => {
        const userIdx = req.decoded.userIdx;
        const folderIdx = req.params.folderIdx;
        let {name} = req.body;
        try{
              if(!name){
                  return res.json({success: false, code: 2201, message: "name을 입력해 주세요"});
              }
              const result = await folderModel.updateFolderName(userIdx, folderIdx, name);
              const folderRow = await folderModel.selectFolderDetail(userIdx, folderIdx);
              if (folderRow[0] == undefined) {
              return res.json({success: false, code: 3202, message: "폴더가 존재하지 않습니다."});
              }
              
              return res.json({success: true, code: 1000, message: "폴더 제목 수정 성공", result: folderRow});
        }catch(err){
            return res.json({success: false, code: 4000, message: 'Server Error : ' + err.message});
        }
    },
    deleteFolder: async (req, res) => {
        const userIdx = req.decoded.userIdx;
        const folderIdx = req.params.folderIdx;
        try{
            const checkFolder = await folderModel.selectFolderDetail(userIdx,folderIdx);
            if (checkFolder[0] == undefined){
                return res.json({success: false, code: 3202, message: "폴더가 존재하지 않습니다."});
            }
            const result = await folderModel.deleteFolder(userIdx,folderIdx);

            return res.json({success: true, code: 1000, message: "폴더 삭제 성공"});
        }catch(err){
            return res.json({success: false, code: 4000, message: 'Server Error : ' + err.message});
        }
    },
    deleteFolderOnly: async (req, res) => {
        const userIdx = req.decoded.userIdx;
        const folderIdx = req.params.folderIdx;
        let {moveFolderIdx} = req.body;
        if(!moveFolderIdx) return res.json({success: true, code: 2202, message: "moveFolderIdx를 입력해 주세요."});

        try{
            const checkFolder = await folderModel.selectFolderDetail(userIdx,folderIdx);
            if (checkFolder[0] == undefined){
                return res.json({success: false, code: 3202, message: "폴더가 존재하지 않습니다."});
            }
            const scrapResult = await scrapModel.moveFolderScrap(userIdx,folderIdx,moveFolderIdx);
            const result = await folderModel.deleteFolder(userIdx,folderIdx);

            return res.json({success: true, code: 1000, message: "폴더 삭제 및 하위 스크랩 이동 성공"});
        }catch(err){
            return res.json({success: false, code: 4000, message: 'Server Error : ' + err.message});
        }
    },
    deleteFolderAll: async (req, res) => {
        const userIdx = req.decoded.userIdx;
        const folderIdx = req.params.folderIdx;
        try{
            const checkFolder = await folderModel.selectFolderDetail(userIdx,folderIdx);
            if (checkFolder[0] == undefined){
                return res.json({success: false, code: 3202, message: "폴더가 존재하지 않습니다."});
            }

            const scrapResult = await scrapModel.deleteFolderScrap(userIdx,folderIdx);
            const result = await folderModel.deleteFolder(userIdx,folderIdx);

            return res.json({success: true, code: 1000, message: "폴더 삭제 및 하위 스크랩 삭제 성공"});
        }catch(err){
            return res.json({success: false, code: 4000, message: 'Server Error : ' + err.message});
        }
    }
}

module.exports = folder;
