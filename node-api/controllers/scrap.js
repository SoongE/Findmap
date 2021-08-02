let userModel = require('../models/users');
let scrapModel = require('../models/scrap');

const scrap = {
    postScrap: async (req, res) => {
        const userIdx = req.decoded.userIdx;
        let {title, contentUrl, thumbnailUrl, summary, comment, categoryIdx, folderIdx} = req.body;

        if (!title || !contentUrl || !thumbnailUrl || !summary || !categoryIdx) {
            return res.json({success: false, code: 2101, message: "스크랩할 내용을 넣어주세요."});
        }
        // comment = null
        if (!folderIdx) {
        //return res.json({success: false, code: 2103, message: "폴더를 지정해주세요."});
            folderIdx = 0; //기본 폴더
        }

        try{
            const result = await scrapModel.postScrap(userIdx, title, contentUrl, thumbnailUrl, summary, comment, categoryIdx, folderIdx, feedIdx);

            return res.json({success: true, code: 1000, message: "스크랩 성공", result: {"insertId": result[0].insertId}});
        } catch(err){
          console.log(error);
          return res.status(4000).send(`Error: ${err.message}`);
        }
    },
    getScrap: async (req, res) => {
        const userIdx = req.decoded.userIdx;

        try {
            let result = ``;
            result = await scrapModel.selectScrap(userIdx);
            if (result[0] == undefined) {
              return res.json({success: true, code: 3101, message: "스크랩이 존재하지 않습니다."});
            }
            return res.json({success: true, code: 1000, message: "스크랩 전체 조회 성공", result: result});
        } catch (err) {
            console.log(error);
            return res.status(4000).send(`Error: ${err.message}`);
        }
    },
    getScrapByFolder: async (req, res) => {
        const userIdx = req.decoded.userIdx;
        let {folderIdx} = req.body;

        if (!folderIdx) {
            return res.json({success: false, code: 2101, message: "조회할 folderIdx를 입력해 주세요."});
        }

        try {
            let result = ``;
            result = await scrapModel.selectScrapByFolder(userIdx,folderIdx);
            if (result[0] == undefined) {
              return res.json({success: true, code: 3101, message: "스크랩이 존재하지 않습니다."});
            }
            return res.json({success: true, code: 1000, message: "스크랩 폴더별 조회 성공", result: result});
        } catch (err) {
            console.log(error);
            return res.status(4000).send(`Error: ${err.message}`);
        }
    },
    getScrapByCategory: async (req, res) => {
        const userIdx = req.decoded.userIdx;
        let {categoryIdx} = req.body;
        if (!categoryIdx) {
            return res.json({success: false, code: 2101, message: "조회할 categoryIdx를 입력해 주세요."});
        }

        try {
            let result = ``;
            result = await scrapModel.selectScrapByCategory(userIdx,categoryIdx);
            if (result[0] == undefined) {
                return res.json({success: true, code: 3101, message: "스크랩이 존재하지 않습니다."});
            }
            return res.json({success: true, code: 1000, message: "스크랩 카테고리별 조회 성공", result: result});
        } catch (err) {
            console.log(error);
            return res.status(4000).send(`Error: ${err.message}`);
        }
    },
    getScrapByDate: async (req, res) => {
        const userIdx = req.decoded.userIdx;
        let {date} = req.body;
        if (!date) {
            return res.json({success: false, code: 2101, message: "조회할 date를 입력해 주세요. 이 때, 형식은 yyyymmdd 로 입력해주세요. (예시:20210723)"});
        }
        
        //"yyyy-mm-dd"
        const regexDate = /^(19|20)\d{2}(0[1-9]|1[012])(0[1-9]|[12][0-9]|3[0-1])$/; 
        if(!regexDate .test(date)){
            return res.json({success: false, code: 2101, message: "입력한 date 형식이 올바르지 않습니다. yyyymmdd 형태로 입력해주세요. (예시:20210723)"});
        }

        //"yyyy-mm-dd HH:MM"
        // const regexDateTime = /^(19|20)\d{2}-(0[1-9]|1[012])-(0[1-9]|[12][0-9]|3[0-1]) (0[0-9]|1[0-9]|2[0-3]):([0-5][0-9])$/; 
        // if(!regexDateTime .test(date)){
        //     return res.json({success: false, code: 2101, message: "입력한 날짜 형식이 올바르지 않습니다."});
        // }

        try {
            let result = ``;
            result = await scrapModel.selectScrapByDate(userIdx,date);
            if (result[0] == undefined) {
                return res.json({success: true, code: 3101, message: "스크랩이 존재하지 않습니다."});
            }
            return res.json({success: true, code: 1000, message: "스크랩 날짜별 조회 성공", result: result});
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
          return res.json({success: true, code: 1000, message: "스크랩 상세 조회 성공", result: scrapRow});
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
                  return res.json({success: false, code: 2111, message: "title을 입력해 주세요"});
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
                return res.json({success: false, code: 2112, message: "summary를 입력해 주세요"});
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
