const axios = require('axios');

let searchModel = require('../models/search');
let userModel = require('../models/users');

const search = {
    getSearchInternet: async (req, res) => {
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

            // 검색어 확인
            var checkSearchWord = await searchModel.selectSearchWord(searchQuery);

            // 검색어 카테고리list 확인
            const response = await axios.get('http://flask-api:5000/search/categorize',{ params: { keyword: searchQuery }});
            const ctglist = response.data.body.ctg;
            const ctg = ctglist.split(",");

            // 검색어 저장 //카테고리list 포함해서 수정하기
            if (checkSearchWord.length < 1) {
                const insertSearchWord = await searchModel.insertSearchWord(searchQuery,ctg[0],ctg[1],ctg[2]);
            } else {
                const updateSearchWord = await searchModel.updateSearchWord(searchQuery);
            }

            // 검색 기록 저장
            var checkSearchWord = await searchModel.selectSearchWord(searchQuery);
            const [searchWord] = checkSearchWord;
            const wordIdx = searchWord.idx;
            const insertSearchLog = await searchModel.insertSearchLog(userIdx,wordIdx);

            return res.json({success: true, code: 1000, message: "검색어,검색 기록 저장 완료"});
        } catch(err){
            return res.json({success: false, code: 4000, message: 'Server Error : ' + err.message});
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

            if(searchResult[0] == undefined) {
                return res.json({success: false, code: 3601, message: "검색 결과가 없습니다."});
            }

            return res.json({success: true, code: 1000, message: "피드 검색 완료", result: searchResult});
        } catch(err){
            return res.json({success: false, code: 4000, message: 'Server Error : ' + err.message});
        }
    },
    getSearchUser: async (req, res) => {
        const userQuery = req.query.query;
        const myIdx = req.decoded.userIdx;

        if (!userQuery) {
            return res.json({success: false, code: 2601, message: "query를 입력해주세요"});
        }

        try {
            const searchResult = await searchModel.searchUser(userQuery,myIdx);

            if(searchResult[0] == undefined) {
                return res.json({success: false, code: 3601, message: "검색 결과가 없습니다."});
            }

            return res.json({success: true, code: 1000, message: "유저 검색 완료", result: searchResult});
        } catch (err) {
            return res.json({success: false, code: 4000, message: 'Server Error : ' + err.message});
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
              return res.json({success: false, code: 3602, message: "검색 기록이 존재하지 않습니다."});
            }

            return res.json({success: true, code: 1000, message: "검색 기록 조회 성공", result: searchRow});
        } catch (err) {
            return res.json({success: false, code: 4000, message: 'Server Error : ' + err.message});
        }
    },
    deleteSearchLog: async (req, res) => {
        const userIdx = req.decoded.userIdx;
        const logIdx = req.query.logIdx;
        if (!logIdx) {
            return res.json({success: false, code: 2602, message: "logIdx를 입력해주세요"});
        }
        try {
            const checkSearchLog = await searchModel.checkSearchLog(userIdx,logIdx);
            if (checkSearchLog[0] == undefined) {
              return res.json({success: false, code: 3602, message: "검색 기록이 존재하지 않습니다."});
            }
            const [searchRow] = await searchModel.deleteSearchLog(userIdx,logIdx);
            return res.json({success: true, code: 1000, message: "검색 기록 삭제 성공"});
        } catch (err) {
            return res.json({success: false, code: 4000, message: 'Server Error : ' + err.message});
        }
    },
    postHotSearchWord: async (req, res) => {
        // const userIdx = req.decoded.userIdx;

        try{
            // 이전 순위 가져오기 
            const getOldRanking = await searchModel.selectOldRanking();

            // 현재 순위 가져오기
            const searchWordResult = await searchModel.selectHotSearchWord();  

            var changes = 'NEW';

            // 처음 순위 매김
            if (getOldRanking.length < 1) {
                for (searchWord of searchWordResult) {
                    // 순위 테이블에 추가
                    console.log(searchWord);
                    const insertRanking = await searchModel.insertRanking(searchWord.idx, searchWord.ranking, changes);
                }
            } else {
                // 기존 순위 테이블 삭제
                const deleteRanking = await searchModel.deleteRanking();

                // 새로운 순위 테이블 추가
                for (searchWord of searchWordResult) {
                    const insertRanking = await searchModel.insertRanking(searchWord.idx, searchWord.ranking, changes);
                }
                
                // 순위 변동 조회
                for (currentSearchWord of searchWordResult) {
                    for (oldSearchWord of getOldRanking) {
                        if (currentSearchWord.idx == oldSearchWord.wordIdx) {
                            // 순위 상승
                            if ((oldSearchWord.ranking - currentSearchWord.ranking) > 0) {
                                changes = `UP ${(oldSearchWord.ranking - currentSearchWord.ranking)}`;
                                const insertChanges = await searchModel.updateChange(currentSearchWord.idx, changes);
                            }
                            // 순위 하락
                            else if ((oldSearchWord.ranking - currentSearchWord.ranking) < 0) {
                                changes = `DOWN ${(currentSearchWord.ranking - oldSearchWord.ranking)}`;
                                const insertChange = await searchModel.updateChange(currentSearchWord.idx, changes);
                            }
                            // 순위 유지
                            else if ((oldSearchWord.ranking - currentSearchWord.ranking) == 0) {
                                changes = `-`;
                                const updateChange = await searchModel.updateChange(currentSearchWord.idx, changes);
                            }
                        }
                    }
                }
                
            }
            return res.json({success: true, code: 1000, message: "검색어 순위 등록 성공"});
        } catch(err){
            return res.json({success: false, code: 4000, message: 'Server Error : ' + err.message});
        }
    },
    getHotSearchWord: async (req, res) => {
        const categoryIdx = req.query.categoryIdx;

        if (!categoryIdx) return res.json({success: false, code: 2603, message: "categoryIdx를 입력해 주세요. 모든 카테고리는 0입니다."});

        try {
            var searchResult;

            if(categoryIdx == 0) {
                searchResult = await searchModel.selectAllRanking();
            } else {
                searchResult = await searchModel.selectRanking(categoryIdx);
            }

            return res.json({success: true, code: 1000, message: "실시간 검색어 조회 성공", result: searchResult});
        } catch (err) {
            return res.json({success: false, code: 4000, message: 'Server Error : ' + err.message});
        }
    }
}

module.exports = search;
