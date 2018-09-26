require! {
    \./mnemonic.ls
}
module.exports = (coin, cb)->
    { create-account, get-balance } = coin
    err, account <- create-account { mnemonic, index }
    return cb err if err?
    err, balance <- get-balance { account }
    return cb err if err?
    return cb "Balance is zero" if +balance is 0
    cb null