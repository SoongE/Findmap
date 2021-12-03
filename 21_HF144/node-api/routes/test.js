const express = require('express');
const router = express.Router();
const axios = require('axios');

/* GET home page. */
router.get('/', (req, res, next) => {
  axios.get('http://flask-api:5000/test')
  .then(response=>res.send(response.data))
  .catch(error=>res.send(error.message))
  .finally();
});

router.get('/name', (req, res, next) => {
  axios.get('http://flask-api:5000/test/name',{ params: { name: 'nodeJS' } })
  .then(response=>res.send(response.data))
  .catch(error=>res.send(error.message))
  .finally();
});
router.get('/recommend/recofeed', (req, res, next) => {
  const useridx = req.query.keyword

  axios.get('http://flask-api:5000/recommend/recofeed',{ params: {useridx : useridx}} )
  .then(response=>res.send(response.data))
  .catch(error=>res.send(error.message))
  .finally();
});
router.get('/recommend/', (req, res, next) => {
  const keyword = req.query.keyword

  axios.get('http://flask-api:5000/recommend',{ params: { keyword: keyword } })
  .then(response=>res.send(response.data))
  .catch(error=>res.send(error.message))
  .finally();
});
router.get('/search', (req, res, next) => {
  const keyword = req.query.keyword
  // const userIdx = req.qeury.userIdx
  const userIdx = 0

  axios.get('http://flask-api:5000/search',{ params: { keyword: keyword , userIdx:userIdx} })
  .then(response=>res.send(response.data))
  .catch(error=>res.send(error.message))
  .finally();
});
router.get('/search/categorize', (req, res, next) => {
  const keyword = req.query.keyword

  axios.get('http://flask-api:5000/search/categorize',{ params: { keyword: keyword } })
  .then(response=>res.send(response.data))
  .catch(error=>res.send(error.message))
  .finally();
});
router.get('/share', (req, res, next) => {
  const url = req.query.url

  axios.get('http://flask-api:5000/search/share',{ params: { url: url } })
  .then(response=>res.send(response.data))
  .catch(error=>res.send(error.message))
  .finally();
});

const body = { 'title': 'Axios POST Request Example' };
router.get('/post', (req,res,next) =>{
  axios.post('http://flask-api:5000/test/post',body)
  .then(response=>res.send(response.data.body['log']))
  .catch(error=>res.send(error.message))
  .finally();
});
router.get('/recommend/initrecom', (req, res, next) => {
  const useridx = req.query.keyword
  
  axios.get('http://flask-api:5000//recommend/initrecom',{ params: { useridx : useridx } })
  .then(response=>res.send(response.data))
  .catch(error=>res.send(error.message))
  .finally();
});
/*router.get('/search/bulcategorize', (req, res, next) => {
  const keyword = req.query.keyword

  axios.get('http://flask-api:5000/search/bulcategorize',{ params: { keyword: keyword } })
  .then(response=>res.send(response.data))
  .catch(error=>res.send(error.message))
  .finally();
});*/

module.exports = router;