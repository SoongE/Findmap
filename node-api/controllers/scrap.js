let userModel = require('../models/users');
let scrapModel = require('../models/scrap');
let folderModel = require('../models/folders');
const regexTest = /^(Y|N)/;
const regexDate = /^(19|20)\d{2}(0[1-9]|1[012])(0[1-9]|[12][0-9]|3[0-1])$/; //"yyyy-mm-dd"

const scrap = {
    postScrap: async (req, res) => {
        const userIdx = req.decoded.userIdx;
        let {title, contentUrl, thumbnailUrl, summary, comment, categoryIdx, folderIdx, isFeed} = req.body; 

        if (!title || !contentUrl || !thumbnailUrl || !summary || !categoryIdx) {
            return res.json({success: false, code: 2101, message: "스크랩할 내용을 넣어주세요."});
        }
        // comment = null
        if (categoryIdx) {
            if (1<=categoryIdx && categoryIdx<=4) return res.json({success: false, code: 2102, message: "1~4는 상위 관심 카테고리를 나타냅니다. 5~36의 하위 관심 카테고리를 선택해주세요."});
            if (categoryIdx<1 || categoryIdx>36) return res.json({success: false, code: 2103, message: "선택할 수 있는 범위를 넘어섰습니다. 5~36의 숫자를 입력해주세요."});
        } 

        if (!folderIdx) {
            //return res.json({success: false, code: 2104, message: "folderIdx를 입력해주세요."});
            folderIdx = 0; //기본 폴더
        }

        if (!isFeed) return res.json({success: false, code: 2105, message: "isFeed 값을 입력해 주세요."});
        if(!regexTest.test(isFeed)) return res.json({success: false, code: 2106, message: "isFeed 형식이 올바르지 않습니다. Y 혹은 N의 형태로 입력해주세요."});


        try{
            const checkFolder = await folderModel.selectFolderDetail(userIdx,folderIdx);
            if (checkFolder[0] == undefined){
                return res.json({success: true, code: 3102, message: "폴더가 존재하지 않습니다."});
            }

            const result = await scrapModel.postScrap(userIdx, title, contentUrl, thumbnailUrl, summary, comment, categoryIdx, folderIdx, isFeed);

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

        if (!folderIdx) return res.json({success: false, code: 2104, message: "조회할 folderIdx를 입력해 주세요."});

        try {
            const checkFolder = await folderModel.selectFolderDetail(userIdx,folderIdx);
            if (checkFolder[0] == undefined){
                return res.json({success: true, code: 3102, message: "폴더가 존재하지 않습니다."});
            }

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
        if (!categoryIdx) return res.json({success: false, code: 2102, message: "조회할 categoryIdx를 입력해 주세요."});
        if (1<=categoryIdx && categoryIdx<=4) return res.json({success: false, code: 2102, message: "1~4는 상위 관심 카테고리를 나타냅니다. 5~36의 하위 관심 카테고리를 선택해주세요."});
        if (categoryIdx<1 || categoryIdx>36) return res.json({success: false, code: 2103, message: "선택할 수 있는 범위를 넘어섰습니다. 5~36의 숫자를 입력해주세요."});

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
        if (!date) return res.json({success: false, code: 2110, message: "조회할 date를 입력해 주세요. 이 때, 형식은 yyyymmdd 로 입력해주세요. (예시:20210723)"});
        if(!regexDate .test(date)){
            return res.json({success: false, code: 2111, message: "입력한 date 형식이 올바르지 않습니다. yyyymmdd 형태로 입력해주세요. (예시:20210723)"});
        }

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
        if(!title) return res.json({success: false, code: 2121, message: "title을 입력해 주세요"});

        try{
            const checkScrap = await scrapModel.selectScrapDetail(userIdx, scrapIdx);
            if (checkScrap[0] == undefined) {
            return res.json({success: true, code: 3101, message: "스크랩이 존재하지 않습니다."});
            }
            const result = await scrapModel.updateScrapTitle(userIdx, scrapIdx, title);
            const scrapRow = await scrapModel.selectScrapDetail(userIdx, scrapIdx);

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
        if(!summary) return res.json({success: false, code: 2122, message: "summary를 입력해 주세요"});
        
        try{
            const checkScrap = await scrapModel.selectScrapDetail(userIdx, scrapIdx);
            if (checkScrap[0] == undefined) {
                return res.json({success: true, code: 3101, message: "스크랩이 존재하지 않습니다."});
            }
            const result = await scrapModel.updateScrapSummary(userIdx, scrapIdx, summary);
            const scrapRow = await scrapModel.selectScrapDetail(userIdx, scrapIdx);
  
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
      if(!comment) return res.json({success: false, code: 2123, message: "comment를 입력해주세요"});

      try{
          const checkScrap = await scrapModel.selectScrapDetail(userIdx, scrapIdx);
          if (checkScrap[0] == undefined) {
              return res.json({success: true, code: 3101, message: "스크랩이 존재하지 않습니다."});
          }
          const result = await scrapModel.updateScrapComment(userIdx, scrapIdx, comment);
          const scrapRow = await scrapModel.selectScrapDetail(userIdx, scrapIdx);

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
        if(!folderIdx) return res.json({success: false, code: 2124, message: "folderIdx를 입력해주세요"});
        
        try {
            const checkScrap = await scrapModel.selectScrapDetail(userIdx, scrapIdx);
            if (checkScrap[0] == undefined) {
                return res.json({success: true, code: 3101, message: "스크랩이 존재하지 않습니다."});
            }
            const checkFolder = await folderModel.selectFolderDetail(userIdx,folderIdx);
            if (checkFolder[0] == undefined){
                return res.json({success: true, code: 3102, message: "폴더가 존재하지 않습니다."});
            }
            const result = await scrapModel.updateScrapFolder(userIdx, scrapIdx, folderIdx);
            const scrapRow = await scrapModel.selectScrapDetail(userIdx, scrapIdx);
            
            return res.json({success: true, code: 1000, message: "스크랩 폴더 수정 성공", result: scrapRow});
        }catch(err){
            console.log(error);
            return res.status(4000).send(`Error: ${err.message}`);
        }
    },
    patchScrapFeedUp: async (req, res) => {
        const userIdx = req.decoded.userIdx;
        const scrapIdx = req.params.scrapIdx;
        
        try {
            const checkScrap = await scrapModel.selectScrapDetail(userIdx, scrapIdx);
            if (checkScrap[0] == undefined) {
                return res.json({success: true, code: 3101, message: "스크랩이 존재하지 않습니다."});
            }
            const result = await scrapModel.updateScrapFeedUp(userIdx, scrapIdx);
            const scrapRow = await scrapModel.selectScrapDetail(userIdx, scrapIdx);
            
            return res.json({success: true, code: 1000, message: "스크랩 피드 올리기 성공", result: scrapRow});
        }catch(err){
            console.log(error);
            return res.status(4000).send(`Error: ${err.message}`);
        }
    },
    patchScrapFeedDown: async (req, res) => {
        const userIdx = req.decoded.userIdx;
        const scrapIdx = req.params.scrapIdx;
        
        try {
            const checkScrap = await scrapModel.selectScrapDetail(userIdx, scrapIdx);
            if (checkScrap[0] == undefined) {
                return res.json({success: true, code: 3101, message: "스크랩이 존재하지 않습니다."});
            }
            const result = await scrapModel.updateScrapFeedDown(userIdx, scrapIdx);
            const scrapRow = await scrapModel.selectScrapDetail(userIdx, scrapIdx);
            
            return res.json({success: true, code: 1000, message: "스크랩 피드 내리기 성공", result: scrapRow});
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
