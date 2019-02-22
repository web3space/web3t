require! {
    \./mnemonic.ls
}
index = 0
module.exports = (coin, cb)->
    { create-account, get-balance, send-all-funds } = coin
    err, account <- create-account { mnemonic, index }
    return cb err if err?
    err, balance <- get-balance { account }
    return cb err if err?
    return cb "Balance is zero" if +balance is 0
    err, recipient <- create-account { mnemonic, index: 1 }
    return cb err if err
    err, tx <- send-all-funds { account, to: recipient.address }
    return cb err if err?
    cb null