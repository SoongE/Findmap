let searchModel = require('../models/search');
let userModel = require('../models/users');

const search = {
    getSearchInternet: async (req, res) => {
        try {
            return res.json({success: true, code: 1000, message: "검색 진행중"});
        } catch (err) {
            return res.json({success: true, code: 4000, message: 'Server Error : ' + err.message});
        }
    },
    getSearchFeed: async (req, res) => {
        let searchQuery;
        const query = req.query.query;
        const userIdx = req.decoded.userIdx;
        
        if (!query) {
            return res.json({success: false, code: 2601, message: "query를 입력해 주세요."});
        }

        try {
             // 로그인 확인
            const checkJWT = await userModel.checkJWT(userIdx);
            if (checkJWT[0].length < 1) return res.json({success: false, code: 3007, message: "로그인되어 있지 않습니다."});

            const searchQuery = query.trim();
 
            const searchResult = await searchModel.searchFeed(searchQuery);

            // 검색 기록 저장
            const insertSearchLog = await searchModel.insertSearchLog(userIdx,searchQuery);

            // 검색어 저장
            const checkSearchWord = await searchModel.selectSearchWord(searchQuery);
            if (checkSearchWord.length < 1) {
                const insertSearchWord = await searchModel.insertSearchWord(searchQuery);
            } else {
                const updateSearchWord = await searchModel.updateSearchWord(searchQuery);
            }

            if(searchResult[0] == undefined) {
                return res.json({success: false, code: 3601, message: "검색 결과가 없습니다."});
            }

            return res.json({success: true, code: 1000, message: "피드 검색 완료", result: searchResult});
        } catch(err){
            return res.json({success: true, code: 4000, message: 'Server Error : ' + err.message});
        }
    },
    getSearchUser: async (req, res) => {
        const userQuery = req.query.query;
        if (!userQuery) {
            return res.json({success: false, code: 2601, message: "query를 입력해주세요"});
        }

        try {
            const searchResult = await searchModel.searchUser(userQuery);

            if(searchResult[0] == undefined) {
                return res.json({success: false, code: 3601, message: "검색 결과가 없습니다."});
            }

            return res.json({success: true, code: 1000, message: "유저 검색 완료", result: searchResult});
        } catch (err) {
            return res.json({success: true, code: 4000, message: 'Server Error : ' + err.message});
        }
    },
    getSearchLog: async (req, res) => {
        const userIdx = req.decoded.userIdx;

        try {
            // 로그인 확인
            const checkJWT = await userModel.checkJWT(userIdx);
            if (checkJWT[0].length < 1) return res.json({success: false, code: 3007, message: "로그인되어 있지 않습니다."});

            const searchRow = await searchModel.selectSearchLog(userIdx);
            if (searchRow[0] == undefined) {
              return res.json({success: true, code: 3602, message: "검색 기록이 존재하지 않습니다."});
            }

            return res.json({success: true, code: 1000, message: "검색 기록 조회 성공", result: searchRow});
        } catch (err) {
            return res.json({success: true, code: 4000, message: 'Server Error : ' + err.message});
        }
    },
    deleteSearchLog: async (req, res) => {
        const userIdx = req.decoded.userIdx;
        const wordIdx = req.query.wordIdx;
        if (!wordIdx) {
            return res.json({success: false, code: 2602, message: "wordIdx를 입력해주세요"});
        }
        try {
            const checkSearchLog = await searchModel.checkSearchLog(userIdx,wordIdx);
            if (checkSearchLog[0] == undefined) {
              return res.json({success: true, code: 3602, message: "검색 기록이 존재하지 않습니다."});
            }
            const [searchRow] = await searchModel.deleteSearchLog(userIdx,wordIdx);
            return res.json({success: true, code: 1000, message: "검색 기록 삭제 성공"});
        } catch (err) {
            return res.json({success: true, code: 4000, message: 'Server Error : ' + err.message});
        }
    },
    postHotSearchWord: async (req, res) => {
        // const userIdx = req.decoded.userIdx;

        try{
            // 이전 순위 가져오기 
            const getOldRanking = await searchModel.selectOldRanking();

            // 현재 순위 가져오기
            const searchWordResult = await searchModel.selectHotSearchWord();  

            var change = 'new';

            // 처음 순위 매김
            if (getOldRanking.length < 1) {
                for (searchWord of searchWordResult) {
                    // 순위 테이블에 추가
                    console.log(searchWord);
                    const insertRanking = await searchModel.insertRanking(searchWord.idx, searchWord.ranking, change);
                }
            } else {
                // 기존 순위 테이블 삭제
                const deleteRanking = await searchModel.deleteRanking();

                // 새로운 순위 테이블 추가
                for (searchWord of searchWordResult) {
                    const insertRanking = await searchModel.insertRanking(searchWord.idx, searchWord.ranking, change);
                }
                
                // 순위 변동 조회
                for (currentSearchWord of searchWordResult) {
                    for (oldSearchWord of getOldRanking) {
                        if (currentSearchWord.idx == oldSearchWord.wordIdx) {
                            // 순위 상승
                            if ((oldSearchWord.ranking - currentSearchWord.ranking) > 0) {
                                change = `UP ${(oldSearchWord.ranking - currentSearchWord.ranking)}`;
                                const insertChange = await searchModel.updateChange(currentSearchWord.idx, change);
                            }
                            // 순위 하락
                            else if ((oldSearchWord.ranking - currentSearchWord.ranking) < 0) {
                                change = `DOWN ${(currentSearchWord.ranking - oldSearchWord.ranking)}`;
                                const insertChange = await searchModel.updateChange(currentSearchWord.idx, change);
                            }
                            // 순위 유지
                            else if ((oldSearchWord.ranking - currentSearchWord.ranking) == 0) {
                                change = `-`;
                                const updateChange = await searchModel.updateChange(currentSearchWord.idx, change);
                            }
                        }
                    }
                }
                
            }
            return res.json({success: true, code: 1000, message: "검색어 순위 등록 성공"});
        } catch(err){
            return res.json({success: true, code: 4000, message: 'Server Error : ' + err.message});
        }
    },
    getHotSearchWord: async (req, res) => {
        try {
            const searchResult = await searchModel.selectRanking();  
            return res.json({success: true, code: 1000, message: "실시간 검색어 조회 성공", result: searchResult});
        } catch (err) {
            return res.json({success: true, code: 4000, message: 'Server Error : ' + err.message});
        }
    },
    getRecommendWord: async (req, res) => {
        try {
            return res.json({success: true, code: 1000, message: "검색어 추천 진행중"});
        } catch (err) {
            return res.json({success: true, code: 4000, message: 'Server Error : ' + err.message});
        }
    }
}

module.exports = search;