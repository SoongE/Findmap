module.exports = function(app) {
    const user = require('../controllers/user');
    //const upload = require('../../modules/multer');
    const authUtil = require('../middlewares/auth').checkToken;

    // 테스트 API
    app.get('/test', user.getTest);

    // 회원가입 API
    app.post('/users', user.signUp);

};