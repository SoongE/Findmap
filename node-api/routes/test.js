const express = require('express');
const router = express.Router();

/* GET home page. */
router.get('/', function(req, res, next) {
  res.render('index', { title: 'Test' });
});

router.get('/name', function(req,res,next) {
    var name = req.query.name;
    res.send(name);
});

module.exports = router;