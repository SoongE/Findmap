const crypto = require('crypto');

const makeSalt = ()=>{
    return crypto.randomBytes(32).toString('hex');
}

const encrypt = (password,salt)=>{
    return new Promise((resolve,reject)=>{
        crypto.pbkdf2(password,salt,1,32,'sha512',(err,derivedKey)=>{
            if(err) throw err;
            const hashed = derivedKey.toString('hex');
            resolve(hashed);
        })
    })
}

module.exports= {
    makeSalt: makeSalt,
    encrypt: encrypt
}