mnemonic = "almost barely slush obey punch ice genius inflict update word engage mercy stadium rotate cable"
index = 0
module.exports = (coin, cb)->
    err, account <- coin.create-account { mnemonic, index }
    return cb "Address is not found" if not account.address?
    return cb "Private Key is not found" if not account.private-key?
    return cb err if err?
    err, balance <- coin.get-balance { account }
    return cb err if err?
    return cb "Balance is wrong" if not balance?
    return cb "Balance should be a string" if balance.to-string!.match(/^[0-9]+$/).length isnt balance.to-string!
    return cb null if +balance is 0
    cb null