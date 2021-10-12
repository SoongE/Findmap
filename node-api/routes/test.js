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
  axios.get('http://flask-api:5000/recommend/recofeed')
  .then(response=>res.send(response.data))
  .catch(error=>res.send(error.message))
  .finally();
});
router.get('/recommend/', (req, res, next) => {
  axios.get('http://flask-api:5000/recommend/')
  .then(response=>res.send(response.data))
  .catch(error=>res.send(error.message))
  .finally();
});
router.get('/search/', (req, res, next) => {
  axios.get('http://flask-api:5000/search/')
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

module.exports = router;