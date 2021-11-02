const axios = require('axios');
let feedModel = require('../models/feeds');
let userModel = require('../models/users');

const search = {
    getTest: async (req, res) => {
        axios.get('http://flask-api:5000/test')
        .then(response=>res.send(response.data))
        .catch(error=>res.send(error.message))
        .finally();
    },
    getRecommendFeeds: async (req, res) => {
        const userIdx = req.decoded.userIdx;
        const scrapIdxList = req.query.scrapIdxList;
        // const useridx = req.query.keyword

        // axios.get('http://flask-api:5000/recommend/recofeed',{ params: {useridx : useridx}} )
        // .then(response=>res.send(response.data))
        // .catch(error=>res.send(error.message))
        // .finally();

        try {
            // 로그인 확인
            const checkJWT = await userModel.checkJWT(userIdx);
            if (checkJWT[0].length < 1) return res.json({success: false, code: 3007, message: "로그인되어 있지 않습니다."});

            if(!scrapIdxList) return res.json({success: false, code: 2030, message: "추천 게시글 인덱스 리스트를 입력해 주세요."});

            // flask 추천 scrapIdx의 scrap 가져오기
            var scrapIdx = scrapIdxList.split(',');
            console.log(scrapIdx.length);
            console.log(scrapIdx);

            var result = new Array();
            for (i = 0; i < scrapIdx.length; i++) {
                const [[feedRow]] = await feedModel.selectRecommendFeed(scrapIdx[i],userIdx);
                if (feedRow != null) {
                    result.push(feedRow);
                }
            }

            return res.json({success: true, code: 1000, message: "추천 게시글 조회 완료", result: result});
        } catch (err) {
            return res.json({success: false, code: 4000, message: 'Server Error : ' + err.message});
        }
    },
    getInitSearchTerm: async (req, res) => {
        const userIdx = req.decoded.userIdx;
  
        axios.get('http://flask-api:5000//recommend/initrecom',{ params: { useridx : userIdx } })
        .then(response=>res.send(response.data))
        .catch(error=>res.send(error.message))
        .finally();
    },
    getRelatedSearchTerm: async (req, res) => {
        const keyword = req.query.keyword;

        if (!keyword) return res.json({success: false, code: 2701, message: "keyword(검색어)를 입력해 주세요."});

        axios.get('http://flask-api:5000/recommend',{ params: { keyword: keyword } })
        .then(response=>res.send(response.data))
        .catch(error=>res.send(error.message))
        .finally();
    },
    getRecommendSearch: async (req, res) => {
        const userIdx = req.decoded.userIdx;
        const keyword = req.query.keyword;

        if (!keyword) return res.json({success: false, code: 2701, message: "keyword(검색어)를 입력해 주세요."});

        axios.get('http://flask-api:5000/search',{ params: { keyword: keyword , userIdx:userIdx} })
        .then(response=>res.send(response.data))
        .catch(error=>res.send(error.message))
        .finally();
    },
    getRecommendCategorizeWord: async (req, res) => {
        const keyword = req.query.keyword

        if (!keyword) return res.json({success: false, code: 2701, message: "keyword(검색어)를 입력해 주세요."});

        axios.get('http://flask-api:5000/search/categorize',{ params: { keyword: keyword} })
        .then(response=>res.send(response.data))
        .catch(error=>res.send(error.message))
        .finally();

        // db에 검색어 3개 저장
    }
}

module.exports = search;
