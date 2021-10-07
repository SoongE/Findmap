let feedModel = require('../models/feeds');
let userModel = require('../models/users');

const feed = {
    patchFeedStorage: async (req, res) => { // 피드 저장 등록/취소
        const userIdx = req.decoded.userIdx;
        const scrapIdx = req.params.scrapIdx;

        try {
            // 로그인 확인
            const checkJWT = await userModel.checkJWT(userIdx);
            if (checkJWT[0].length < 1) return res.json({success: false, code: 3007, message: "로그인되어 있지 않습니다."});

            const [checkStorage] = await feedModel.checkStorage(userIdx,scrapIdx);

            if (checkStorage.length < 1) { //FeedStorage가 존재하지 않는다면

                const result = await feedModel.postStorage(userIdx,scrapIdx);
                return res.json({success: true, code: 1000, message: "피드 저장 성공"});

            } else { //FeedStorage가 존재한다면

                if (checkStorage[0].status == 'Y'){
                    const result = await feedModel.deleteStorage(userIdx,scrapIdx);
                    return res.json({success: true, code: 1000, message: "피드 저장 취소 성공"});
                } 
                if (checkStorage[0].status == 'D'){
                    const result = await feedModel.reuseStorage(userIdx,scrapIdx);
                    return res.json({success: true, code: 1000, message: "피드 재저장 성공"});
                }
            }

        } catch (err) {
            return res.json({success: true, code: 4000, message: 'Server Error : ' + err.message});
        }
    },
    patchFeedHeart: async (req, res) => { // 피드 저장 등록/취소
        const userIdx = req.decoded.userIdx;
        const scrapIdx = req.params.scrapIdx;

        try {
            // 로그인 확인
            const checkJWT = await userModel.checkJWT(userIdx);
            if (checkJWT[0].length < 1) return res.json({success: false, code: 3007, message: "로그인되어 있지 않습니다."});

            const [checkHeart] = await feedModel.checkHeart(userIdx,scrapIdx);
            console.log(checkHeart[0]);

            if (checkHeart.length < 1) { //FeedHeart가 존재하지 않는다면

                const result = await feedModel.postHeart(userIdx,scrapIdx);
                return res.json({success: true, code: 1000, message: "피드 하트 성공"});

            } else { //FeedHeart가 존재한다면

                
                if (checkHeart[0].status == 'Y'){
                    const result = await feedModel.deleteHeart(userIdx,scrapIdx);
                    return res.json({success: true, code: 1000, message: "피드 하트 취소 성공"});
                } 
                if (checkHeart[0].status == 'D'){
                    const result = await feedModel.reuseHeart(userIdx,scrapIdx);
                    return res.json({success: true, code: 1000, message: "피드 재하트 성공"});
                }
            }

        } catch (err) {
            return res.json({success: true, code: 4000, message: 'Server Error : ' + err.message});
        }
    },
    patchFeedHistory: async (req, res) => { // 피드 저장 등록/취소
        const userIdx = req.decoded.userIdx;
        const scrapIdx = req.params.scrapIdx;
        let addCount;

        try {
            // 로그인 확인
            const checkJWT = await userModel.checkJWT(userIdx);
            if (checkJWT[0].length < 1) return res.json({success: false, code: 3007, message: "로그인되어 있지 않습니다."});

            const [checkHistory] = await feedModel.checkHistory(userIdx,scrapIdx);

            if (checkHistory.length < 1) { //FeedHistory가 존재하지 않는다면

                const result = await feedModel.postHistory(userIdx,scrapIdx);
                return res.json({success: true, code: 1000, message: "피드 방문 성공"});

            } else { //FeedHistory가 존재한다면
                // count 높이기
                addCount = checkHistory[0].count + 1;
                const result = await feedModel.addCountHistory(userIdx,scrapIdx,addCount);

                return res.json({success: true, code: 1000, message: "피드 재방문 성공"});
            }

        } catch (err) {
            return res.json({success: true, code: 4000, message: 'Server Error : ' + err.message});
        }
    },
    getFeedProfile: async (req, res) => {
        const myIdx = req.decoded.userIdx;
        const userIdx = req.query.userIdx;

        if (!userIdx) return res.json({success: false, code: 2501, message: "userIdx를 입력해주세요."});
        
        try {
            const [profileRow] = await feedModel.selectProfile(userIdx,myIdx);

            if (profileRow[0] == undefined){
                return res.json({success: false, code: 3501, message: "유저 프로필 정보가 존재하지 않습니다."});
            }

            return res.json({success: true, code: 1000, message: "유저 정보 조회 성공", result: profileRow});
        } catch (err) {
            return res.json({success: true, code: 4000, message: 'Server Error : ' + err.message});
        }
    },
    getFeed: async (req, res) => {
        const userIdx = req.query.userIdx;

        if (!userIdx) return res.json({success: false, code: 2501, message: "userIdx를 입력해주세요."});
        
        try {
            const [feedRow] = await feedModel.selectFeed(userIdx);

            // if (feedRow[0] == undefined){
            //     return res.json({success: false, code: 3502, message: "피드 정보가 존재하지 않습니다."});
            // }
            // 피드가 없어도 조회는 되어야하므로 에러 처리가 필요없다.

            return res.json({success: true, code: 1000, message: "유저 피드 조회 성공", result: feedRow});
        } catch (err) {
            return res.json({success: true, code: 4000, message: 'Server Error : ' + err.message});
        }
    },
    getRecommendationFeed: async (req, res) => {
        const userIdx = req.decoded.userIdx;
        
        try {
            // 로그인 확인
            const checkJWT = await userModel.checkJWT(userIdx);
            if (checkJWT[0].length < 1) return res.json({success: false, code: 3007, message: "로그인되어 있지 않습니다."});
            
            // const feedRow // flask 추천

            return res.json({success: true, code: 1000, message: "추천 피드 조회 진행중"});
        } catch (err) {
            return res.json({success: true, code: 4000, message: 'Server Error : ' + err.message});
        }
    },
    getFollowingFeed: async (req, res) => {
        const userIdx = req.decoded.userIdx;
        
        try {
            // 로그인 확인
            const checkJWT = await userModel.checkJWT(userIdx);
            if (checkJWT[0].length < 1) return res.json({success: false, code: 3007, message: "로그인되어 있지 않습니다."});
            
            const feedRow = await feedModel.selectFollowingFeed(userIdx);
            return res.json({success: true, code: 1000, message: "팔로잉 피드 조회 성공", result: feedRow[0]});
        } catch (err) {
            return res.json({success: true, code: 4000, message: 'Server Error : ' + err.message});
        }
    }
}

module.exports = feed;