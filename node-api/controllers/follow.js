let userModel = require('../models/users');
let followModel = require('../models/follow');

const users = {
    patchFollow: async (req, res) => { // 팔로우 등록, 취소
        const followerIdx = req.decoded.userIdx;
        let {followingIdx} = req.body;

        if (!followingIdx) return res.json({success: false, code: 2401, message: "followingIdx를 입력해 주세요."});
        if (followerIdx == followingIdx) return res.json({success: false, code: 2402, message: "본인을 팔로우할 수 없습니다."});

        try {
            // 로그인 확인
            const checkJWT = await userModel.checkJWT(followerIdx);
            if (checkJWT[0].length < 1) return res.json({success: false, code: 3007, message: "로그인되어 있지 않습니다."});

            const [checkFollow] = await followModel.checkFollow(followerIdx,followingIdx);

            if (checkFollow.length < 1) { //follow가 존재하지 않는다면

                const result = await followModel.postFollow(followerIdx,followingIdx);
                return res.json({success: true, code: 1000, message: "팔로우 성공"});

            } else { //follow가 존재한다면

                if (checkFollow[0].status == 'Y'){
                    const result = await followModel.deleteFollow(followerIdx,followingIdx);
                    return res.json({success: true, code: 1000, message: "팔로우 취소 성공"});
                } 
                if (checkFollow[0].status == 'D'){
                    const result = await followModel.reuseFollow(followerIdx,followingIdx);
                    return res.json({success: true, code: 1000, message: "재팔로우 성공"});
                }
            }

        } catch (err) {
            console.log(error);
            return res.status(4000).send(`Error: ${err.message}`);
        }
    },
    getFollowerList: async (req, res) => {
        const userIdx = req.decoded.userIdx;
        
        try {
            // 로그인 확인
            const checkJWT = await userModel.checkJWT(userIdx);
            if (checkJWT[0].length < 1) return res.json({success: false, code: 3007, message: "로그인되어 있지 않습니다."});

            // 팔로워가 있는지 확인
            const [checkFollowing] = await followModel.checkFollowing(userIdx);
            if (checkFollowing[0] == undefined){
                return res.json({success: true, code: 3401, message: "팔로워가 존재하지 않습니다."});
            }
            
            const followerRow = await followModel.selectFollowerList(userIdx);
            return res.json({success: true, code: 1000, message: "팔로워 리스트 조회 성공", result: followerRow[0]});
        } catch (err) {
            console.log(error);
            return res.status(4000).send(`Error: ${err.message}`);
        }
    },
    getFollowingList: async (req, res) => {
        const userIdx = req.decoded.userIdx;
        
        try {
            // 로그인 확인
            const checkJWT = await userModel.checkJWT(userIdx);
            if (checkJWT[0].length < 1) return res.json({success: false, code: 3007, message: "로그인되어 있지 않습니다."});
            
            // 팔로잉이 있는지 확인
            const [checkFollower] = await followModel.checkFollower(userIdx);
            if (checkFollower[0] == undefined){
                return res.json({success: true, code: 3402, message: "팔로잉이 존재하지 않습니다."});
            }

            const followingRow = await followModel.selectFollowingList(userIdx);
            return res.json({success: true, code: 1000, message: "팔로잉 리스트 조회 성공", result: followingRow[0]});
        } catch (err) {
            console.log(error);
            return res.status(4000).send(`Error: ${err.message}`);
        }
    }
}

module.exports = users;