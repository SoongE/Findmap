let userModel = require('../models/users');
let scrapModel = require('../models/scrap');

const scrap = {
    postScrap: async (req, res) => {
        const userIdx = req.decoded.userIdx;
        let {title, contentUrl, thumbnailUrl, summary, comment, categoryIdx, folderIdx, feedIdx} = req.body;

        try{
            if (!title || !contentUrl || !thumbnailUrl || !summary || !categoryIdx) {
              return res.json({success: false, code: 2101, message: "스크랩할 내용을 넣어주세요."});
            }
            // if (!comment) {
            //   //return res.json({success: false, code: 2102, message: "스크랩에 대한 의견을 적어주세요!"});
            //   // comment = null
            // }
            if (!folderIdx) {
              //return res.json({success: false, code: 2103, message: "폴더를 지정해주세요."});
              folderIdx = 0; //기본 폴더
            }

            const result = await scrapModel.postScrap(userIdx, title, contentUrl, thumbnailUrl, summary, comment, categoryIdx, folderIdx, feedIdx);

            return res.json({success: true, code: 1000, message: "스크랩 성공", result: {"insertId": result[0].insertId}});

        }catch(err){
          console.log(error);
          return res.status(4000).send(`Error: ${err.message}`);
        }
    },
    getScrap: async (req, res) => {
        const userIdx = req.decoded.userIdx;

        try {
            let selectMyArchive = ``;
            selectMyArchive = await scrapModel.selectScrap(userIdx);
            return res.json({success: true, code: 1000, message: "나의 스크랩 전체 조회 성공", result: selectMyArchive});
        } catch (err) {
            console.log(error);
            return res.status(4000).send(`Error: ${err.message}`);
        }
    },
    getScrapDetail: async (req, res) => {
      const userIdx = req.decoded.userIdx;
      const scrapIdx = req.params.scrapIdx;

      try {
          const scrapRow = await scrapModel.selectScrapDetail(userIdx,scrapIdx);

          if (scrapRow[0] == undefined) {
                return res.json({success: true, code: 3101, message: "스크랩이 존재하지 않습니다."});
          }

          return res.json({success: true, code: 1000, message: "나의 스크랩 상세 조회 성공", result: selectMyScrap});
      } catch (err) {
          console.log(error);
          return res.status(4000).send(`Error: ${err.message}`);
      }
    },
    patchScrapTitle: async (req, res) => {
        const userIdx = req.decoded.userIdx;
        const scrapIdx = req.params.scrapIdx;
        let {title} = req.body;
        try{
              if(!title){
                  return res.json({success: false, code: 2111, message: "title을 입력해주세요"});
              }
              const result = await scrapModel.updateScrapTitle(userIdx, scrapIdx, title);
              const scrapRow = await scrapModel.selectScrapDetail(userIdx, scrapIdx);
              if (scrapRow[0] == undefined) {
              return res.json({success: true, code: 3101, message: "스크랩이 존재하지 않습니다."});
              }
              
              return res.json({success: true, code: 1000, message: "스크랩 제목 수정 성공", result: scrapRow});
        }catch(err){
            console.log(error);
            return res.status(4000).send(`Error: ${err.message}`);
        }
      },
    patchScrapSummary: async (req, res) => {
        const userIdx = req.decoded.userIdx;
        const scrapIdx = req.params.scrapIdx;
        let {summary} = req.body;
        try{
            if(!summary){
                return res.json({success: false, code: 2112, message: "summary를 입력해주세요"});
            }
  
            const result = await scrapModel.updateScrapSummary(userIdx, scrapIdx, summary);
            const scrapRow = await scrapModel.selectScrapDetail(userIdx, scrapIdx);
            if (scrapRow[0] == undefined) {
              return res.json({success: true, code: 3101, message: "스크랩이 존재하지 않습니다."});
            }
  
            return res.json({success: true, code: 1000, message: "스크랩 줄거리 수정 성공", result: scrapRow});
        }catch(err){
            console.log(error);
            return res.status(4000).send(`Error: ${err.message}`);
        }
      },
    patchScrapComment: async (req, res) => {
      const userIdx = req.decoded.userIdx;
      const scrapIdx = req.params.scrapIdx;
      let {comment} = req.body;
      try{
          if(!comment){
              return res.json({success: false, code: 2113, message: "comment를 입력해주세요"});
          }

          const result = await scrapModel.updateScrapComment(userIdx, scrapIdx, comment);
          const scrapRow = await scrapModel.selectScrapDetail(userIdx, scrapIdx);
          if (scrapRow[0] == undefined) {
            return res.json({success: true, code: 3101, message: "스크랩이 존재하지 않습니다."});
          }

          return res.json({success: true, code: 1000, message: "스크랩 코멘트 수정 성공", result: scrapRow});
      }catch(err){
          console.log(error);
          return res.status(4000).send(`Error: ${err.message}`);
      }
    },
    patchScrapFolder: async (req, res) => {
        const userIdx = req.decoded.userIdx;
        const scrapIdx = req.params.scrapIdx;
        let {folderIdx} = req.body;
        try{
            if(!folderIdx){
                return res.json({success: false, code: 2114, message: "folderIdx를 입력해주세요"});
            }
            
            const result = await scrapModel.updateScrapFolder(userIdx, scrapIdx, folderIdx);
            const scrapRow = await scrapModel.selectScrapDetail(userIdx, scrapIdx);
            if (scrapRow[0] == undefined) {
                return res.json({success: true, code: 3101, message: "스크랩이 존재하지 않습니다."});
            }
            
            return res.json({success: true, code: 1000, message: "스크랩 폴더 수정 성공", result: scrapRow});
        }catch(err){
            console.log(error);
            return res.status(4000).send(`Error: ${err.message}`);
        }
    },
    deleteScrap: async (req, res) => {
        const userIdx = req.decoded.userIdx;
        const scrapIdx = req.params.scrapIdx;
        try{
            const checkScrap = await scrapModel.selectScrapDetail(userIdx,scrapIdx);
            if (checkScrap[0] == undefined){
                return res.json({success: true, code: 3101, message: "스크랩이 존재하지 않습니다."});
            }
            const result = await scrapModel.deleteScrap(userIdx,scrapIdx);
            return res.json({success: true, code: 1000, message: "스크랩 삭제 성공"});
        }catch(err){
            console.log(error);
            return res.status(4000).send(`Error: ${err.message}`);
        }
    }
}

module.exports = scrap;
