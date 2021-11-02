var express = require('express');
var router = express.Router();
var schedule = require('node-schedule');

let userModel = require('../models/users');

const search = {
    getShare: async (req, res) => {
        const url = req.query.url
  
        axios.get('http://flask-api:5000/search/share',{ params: { url: url } })
        .then(response=>res.send(response.data))
        .catch(error=>res.send(error.message))
        .finally();
    },
    getCrawl: async (req,res) => {

        try {

            // 10초마다 실행하는 코드
            schedule.scheduleJob('10 * * * * *', async()=>{ 
                console.log('10초마다 실행!');

                // axios.get('http://flask-api:5000/search/categorize',{ params: { keyword: keyword , userIdx:userIdx} })
                // .then(response=>res.send(response.data))
                // .catch(error=>res.send(error.message))
                // .finally();
            })

            // 날짜를 지정해서 실행하는 코드 //일요일 2시 30분
            var j = schedule.scheduleJob({hour: 14, minute: 30, dayOfWeek: 0}, function(){ 
                console.log('일요일 2시 30분에 실행');
            });

            //var date = new Date(2021, 11, 2, 5, 30, 0);
            // var j = schedule.scheduleJob(date, function(){
            //     console.log('날짜 지정');
            // });

            return res.json({success: true, code: 1000, message: "실시간 크롤링 시작"});
        } catch (err) {
            return res.json({success: false, code: 4000, message: 'Server Error : ' + err.message});
        }
    }
}

module.exports = search;