const express = require('express');
const router = express.Router();

/* GET home page. */
router.get('/', function(req, res, next) {
  res.render('index', { title: 'Express' });
});

router.use('/test', require('./test'));
router.use('/users', require('./users'));
router.use('/scrap',require('./scrap'));
router.use('/folders',require('./folders'));
router.use('/follow',require('./follow'));

module.exports = router;