require! {
    \./example-1-core.ls : { init-web3t }
    \./example-2-create_accounts.ls : {
        create-btc-account
        create-ltc-account
        create-stt-account
    }
}

export get-btc-balance = (cb)->
    err, account <- create-btc-account 0
    return cb err if err?
    err, web3t <- init-web3t
    return cb err if err?
    web3t.btc.get-balance { account }, cb
    
    
export get-ltc-balance = (cb)->
    err, account <- create-ltc-account 0
    return cb err if err?
    err, web3t <- init-web3t
    return cb err if err?
    web3t.ltc.get-balance { account }, cb


export get-stt-balance = (cb)->
    err, account <- create-stt-account 0
    return cb err if err?
    err, web3t <- init-web3t
    return cb err if err?
    web3t.stt.get-balance { account }, cb

# Everything else is the same
    