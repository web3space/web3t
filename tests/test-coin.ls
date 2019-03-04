require! {
    \./test-coin-non-zero.ls
    \./mnemonic.ls
}
index = 0
module.exports = (type, coin, cb)->
    console.log type
    { create-account, get-balance, calc-fee } = coin
    return cb "Create Account is not a function" if typeof! create-account isnt \Function
    return cb "Get Balance is not a function" if typeof! get-balance isnt \Function
    err, account <- create-account { mnemonic, index }
    return cb "Address is not found" if not account.address?
    return cb "Private Key is not found" if not account.private-key?
    return cb err if err?
    err, balance <- get-balance { account }
    return cb err if err?
    return cb "Balance is wrong" if not balance?
    return cb null if +balance is 0
    #err <- test-coin-non-zero coin
    #return cb err if err?
    cb null