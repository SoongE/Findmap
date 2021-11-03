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

        axios.get('http://flask-api:5000/recommend/recofeed',{ params: {useridx : userIdx}} )
        .then(response=>res.send(response.data))
        .catch(error=>res.send(error.message))
        .finally();
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

        axios.get('http://flask-api:5000/search',{ params: { keyword: keyword , userIdx: userIdx} })
        .then(response=>res.send(response.data))
        .catch(error=>res.send(error.message))
        .finally();
    },
    getRecommendCategorizeWord: async (req, res) => {
        const keyword = req.query.keyword

        if (!keyword) return res.json({success: false, code: 2701, message: "keyword(검색어)를 입력해 주세요."});

        axios.get('http://flask-api:5000/search/categorize',{ params: { keyword: keyword } })
        .then(response=>res.send(response.data))
        .catch(error=>res.send(error.message))
        .finally();
        
    }
}

module.exports = search;
