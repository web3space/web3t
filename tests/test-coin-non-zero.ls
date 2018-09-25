require! {
    \./mnemonic.ls
}

module.exports = (coin, cb)->
    err, account <- coin.create-account { mnemonic, index }
    return cb err if err?
    err, balance <- coin.get-balance { account }
    return cb err if err?
    return cb "Balance is Zero" if +balance is 0
    cb null
    
    