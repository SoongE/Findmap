const express = require('express');
const router = express.Router();
const axios = require('axios');

/* GET home page. */
router.get('/', (req, res, next) => {
  axios.get('http://flask-api:5000/whoyouare',{ params: { 'name': "nodeJS" } })
  .then(response=>res.send(response.data))
  .catch(error=>res.send(error.message))
  .finally();
});

router.get('/name', function(req,res,next) {
    var name = req.query.name;
    res.send(name);
});

module.exports = router;