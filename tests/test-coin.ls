mnemonic = "almost barely slush obey punch ice genius inflict update word engage mercy stadium rotate cable"
index = 0
module.exports = (coin, cb)->
    err, account <- coin.create-account { mnemonic, index }
    return cb err if err?
    console.log account
    cb null