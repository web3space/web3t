require! {
    \./test-coin-non-zero.ls
    \./mnemonic.ls
}
index = 0
module.exports = (coin, cb)->
    { create-account, get-balance } = coin
    return cb "Create Account is not a function" if typeof! create-account isnt \Function
    return cb "Get Balance is not a function" if typeof! get-balance isnt \Function
    err, account <- create-account { mnemonic, index }
    return cb "Address is not found" if not account.address?
    return cb "Private Key is not found" if not account.private-key?
    #console.log account.address
    return cb err if err?
    err, balance <- get-balance { account }
    return cb err if err?
    return cb "Balance is wrong" if not balance?
    #console.log balance
    return cb "Balance should be a string" if balance.to-string!.match(/^[0-9]+$/)?[0] isnt balance.to-string!
    return cb null if +balance is 0
    err <- test-coin-non-zero coin
    return cb err if err?
    cb null