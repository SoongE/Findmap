let responseMsg = require('../modules/responseMessage');
let statusCode = require('../modules/statusCode');
let util = require('../modules/util');
let user = require('../models/user');

/*
    API Name : test API
    [GET] /test
    마지막 수정 : 2021.06.15
*/
exports.getTest = async (req, res) => {
    res.status(statusCode.OK).send(util.success(statusCode.OK, responseMsg.SUCCESS));
}