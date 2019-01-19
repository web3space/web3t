require! {
    \./example-1-core.ls : { init-web3t }
    \./example-2-create_accounts.ls : {
        create-btc-account
        create-ltc-account
        create-stt-account
    }
}

export send-btc-transaction = (cb)->
    err, account <- create-btc-account 0
    return cb err if err?
    err, web3t <- init-web3t
    return cb err if err?
    err, account-receiver <- create-btc-account 1
    const to = account-receiver.address
    const amount = "1"
    web3t.btc.send-transaction { account, to, amount }, cb
    
    
export send-ltc-transaction = (cb)->
    err, account <- create-ltc-account 0
    return cb err if err?
    err, web3t <- init-web3t
    return cb err if err?
    err, account-receiver <- create-ltc-account 1
    const to = account-receiver.address
    const amount = "1"
    web3t.ltc.send-transaction({ account, to, amount }, cb)


export send-stt-transaction = (cb)->
    err, account <- create-stt-account 0
    return cb err if err?
    err, web3t <- init-web3t
    return cb err if err?
    err, account-receiver <- create-stt-account 1
    const to = account-receiver.address
    const amount = "1"
    web3t.stt.send-transaction({ account, to, amount }, cb)
    
# Everything else is the same
    